import boto3
import json
from datetime import datetime
import logging
from botocore.exceptions import ClientError
import pg8000
from pprint import pprint
import logging
import pandas as pd

# Temporary Data for Development:
# with open('././files/dbdata.json') as file:
#     temp_data = json.loads(file.read())


def get_totesys_details():
    """
    Args: None

    Returns: JSON object with database credentials
    for totesys database.
    """
    secret_name = "psql"
    parameter_name = "db_endpoint"
    client_secret = boto3.client('secretsmanager')
    client_parameter = boto3.client('ssm')
    try:
        password = client_secret.get_secret_value(SecretId=secret_name)
        db_cred = client_parameter.get_parameter(Name=parameter_name)

    except ClientError as e:
        print('HERE')
        raise e
    db_endpoint = db_cred['Parameter']['Value'][:-5]
    conn = {'password': password['SecretString'],
            'host': db_endpoint, 'port': 5432, 'user': 'postgres'}
    return conn


def get_bucket_names():
    """
    Args:
    ------
    None.

    Returns:
    ------
    Object containing names of S3 buckets. Example:

    {'ingestion': 'ingestion-20240304201826545600000001',
    'process': 'process-20240304201826547200000003',
    'storage': 'storage-20240304201826546800000002'}

    """
    client = boto3.client('ssm')
    bucket_obj = {'ingestion': None, 'process': None,
                  'storage': None}
    for name in bucket_obj:
        bucket_obj[name] = client.get_parameter(
            Name=f"/{name}")['Parameter']['Value']
    return bucket_obj


def get_aws_time():
    """
    ## Args:
    None.
    ---
    ## Returns:
    ---
    - datetime object stored in aws parameters store.

    This function accesses the time stored in AWS Parameter Store.
    This function will return a datetime OBJECT.
    """
    client = boto3.client('ssm')
    str = client.get_parameter(Name='/time')['Parameter']['Value']
    # return datetime.strptime(str, '%Y-%m-%d %H:%M:%S.%f')
    return str


def update_aws_time(datetime):
    """
    ## Args:
    ---
    datetime object.
    ---
    ## Returns:
    Updates time in aws parameter store.  Does not return anything.
    ---
    - `str`
    Returns a message: "File path created: {date_str}.  File added!"
    This function will update the time stored in the AWS Parameter Store.
    The function should take a datetime object.
    It does not return anything.
    """
    to_string = datetime.strftime('%Y-%m-%d %H:%M:%S.%f')
    client = boto3.client('ssm')
    client.put_parameter(
        Name='/time',
        Value=to_string,
        Type='String',
        Overwrite=True)

# Functions for Ingestion Lambda:


def all_data():
    """
        ---
    ## Args:
    ---
    No Arguments.
    ---
    ## Returns:
    ---
    - `str`
    Returns a json string with the latest data.
    ```
    This function will compare 'last_updated' fields to
    time stored in aws_parameter store.  If the last_updated time
    is ahead of aws_parameter store, it will pull
    that information out of the database.
    It is used to scan the database to find recently updated records.
    When it has finished, it will update the time in the aws_parameter store.
    """
    # Returns datetime object from last query time.
    last_query_time = get_aws_time()
    table_dict = {'counterparty': None, 'currency': None,
                  'department': None, 'design': None,
                  'staff': None, 'sales_order': None,
                  'address': None, 'payment': None,
                  'purchase_order': None, 'payment_type': None,
                  'transaction': None}

    # Establish a connection to the PostgreSQL database
    dbCred = get_totesys_details()

    con = pg8000.connect(**dbCred)
    data = {}
    # Iterate through table_dict
    for table in table_dict:
        # For each Table
        cursor = con.cursor()
        query = (f"SELECT * FROM {table} "
                 f"WHERE last_updated > '{last_query_time}';")
        cursor.execute(query)
    # Establish names of columns
        column_names = [col_desc[0] for col_desc in cursor.description]
        rows = con.run(query)
        list = []
    # Iterate through each ROW.
        for row in rows:
            # Create temp dictionary
            temp = {}
        # Iterate through data in each row:
            for i, x in enumerate(row):
                # Add to my_row dictionary: column name (i).
                # Value is (x)
                temp[column_names[i]] = x
        # Append dictionary to list.
            list.append(temp)
    # Add to dictionary.  Table name is key.  List is value.
    data[table] = list
    con.close()
    # Convert into a JSON string:
    json_str = json.dumps(data, default=str, indent=2)
    # Update AWS time to set time of 'last update':
    update_aws_time(datetime.now())
    return json_str


def create_path_add_file(file, bucket_name=get_bucket_names()['ingestion']):
    """
       ---
    ## Args:
    ---
    JSON String.
    bucket_name - OPTIONAL
    Default bucket name is 'ingestion' bucket name.
    ---
    ## Returns:
    ---
    - `str`
    Returns a message: "File path created: {date_str}.  File added!"

    This function creates a file path in an S3 bucket and
    adds a json to the created file path.

    In order to maintain a clean file structure within
    the S3 bucket, this function will try to create a unique file path.
    The file path is set to the time the function is
    run and will create a file path in this format:
    Year/Month/Date/Hour
    2023/2/16/12
    This assumes that the function was run about
    12pm on the 16th February 2023.
    If the file path already exists, it will not create a new file path.

    This function accepts two arguments; a json string and a bucket name.

    The bucket name is set to a default value of 'ingestion-123'.

    If the file is NOT a json file, it will raise a value error.

    If the file IS a json file, it will create a file path
    (assuming it does not exist already) and place
    the json file in the final folder.

    """

    # Check that File is a VALID JSON file.
    try:
        dict_values = json.loads(file).values()
        print("Valid JSON provided.  Checking for values...")
    except (json.JSONDecodeError, TypeError):
        raise ValueError("File is not valid JSON format.")

    # Check JSON not empty
    # If JSON totaly empty, returns.
    if all(len(value) == 0 for value in dict_values):
        print('No new values detected.  Update unnecessary')
        return None

    s3 = boto3.client('s3')
    current_time = datetime.now()
    current_time_str = current_time.strftime("%Y%m%d%H%M%S")
    # Create a date dictionary to iterate over.
    date_dict = {'year': current_time.year, 'month': current_time.month,
                 'day': current_time.day, 'hour': current_time.hour}
    # Date string added to to create file path.
    date_str = ""
    # Iterate through date dictionary:
    for time in date_dict:
        date_str += f"{date_dict[time]}/"
        try:
            # Checks if file path exists.
            s3.head_object(Bucket=bucket_name, Key=date_str)
            print(f"File path: {date_str} already exists continuing...")
            continue
        except Exception as e:
            print(e)
            # If file path does not exist.  Create file path.
            try:
                print(
                    f"File path: {date_str} does not exist."
                    f"Creating file path now...")
                s3.put_object(Key=date_str, Bucket=bucket_name)
                print(f"{date_str} created successfully.")
            except Exception as e:
                return e
    # File path exists, will now attempt to place
    # JSON object into the file path location.
    # Create a unique file name.
    try:
        file_name = f"{date_str}{current_time_str}.json"
        # Add file to the file location created earlier.
        s3.put_object(Body=file, Bucket=bucket_name, Key=file_name)
        # Update AWS Time
    except Exception as e:
        return e

    # Updated AWS Time in AWS Parameter store:
    try:
        update_aws_time(datetime.now())
    except Exception as e:
        return e

    return f"File path created: {date_str}.  File added: {current_time_str}.json!"


# Functions for Transformation Lambda:
def process_write(event):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    try:
        # Log the incoming event
        logger.info("Received event: %s", json.dumps(event, indent=2))

        s3 = boto3.client('s3')

        # Discover new file location:
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        file = event['Records'][0]['s3']['object']['key']

        # Access the data from ingestion bucket:
        data = json.loads(s3.get_object(
            Bucket=bucket_name, Key=file)['Body'].read())

        # Access data:
        # Access name of process bucket to write to:
        process_bucket_name = get_bucket_names()['process']
        # Extract data
        counterparty = json.dumps(data['counterparty'])

        # Write to S3 bucket; 'process'.
        response = s3.put_object(Body=counterparty, Bucket=process_bucket_name,
                                 Key='Counterparty Data')

    # Handle response status code.  Check for write success:
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            return {'status': 'Success', 'message': 'Object added!'}
        else:
            return {'status': 'Failed', 'message': 'Object not added!', 'bucket_name': bucket_name, 'key': file, 'response': response}
    except Exception as e:
        return {'Status': 'Error', 'message': str(e)}


def dim_counterparty(file):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    s3 = boto3.client('s3')
    """
    Args:
    This function accepts a JSON file.
    The JSON should not be in string format.

    Returns:
    If no dim_counterparty dataframe in 'process' bucket, creates
    dim_counterparty dataframe and populates with updated data.

    If dataframe exists already, populates with new data.
    """

    # Exit function if not enough data provided:
    if len(file['counterparty']) == 0:
        return 'No counterparty data.'
    elif len(file['address']) == 0:
        return 'No address data.'

    counterparty = file['counterparty']
    address = file['address']
    bucket_name = get_bucket_names()['process']
    key = '/counterparty'

    # Create dim_counterparty Object
    dim_counterparty = []

    for record in counterparty:
        schema = {'counterparty_id': record['counterparty_id'],
                  'counterparty_legal_name': record['counterparty_legal_name']}
        for item in address:
            if item['address_id'] == record['legal_address_id']:
                schema['counterparty_legal_address_line_1'] = str(
                    item['address_line_1'])
                schema['counterparty_legal_address_line_2'] = str(
                    item['address_line_2'])
                schema['counterparty_legal_district'] = str(
                    item['district'])
                schema['counterparty_legal_city'] = str(item['city'])
                schema['counterparty_legal_postal_code'] = str(
                    item['postal_code'])
                schema['counterparty_legal_country'] = str(item['country'])
                schema['counterparty_legal_phone_number'] = str(item['phone'])

                break
        dim_counterparty.append(schema)
    try:
        # Convert to Pandas Data Frame:
        df = pd.DataFrame(data=dim_counterparty)
        print(df)
        print('Pandas Data Frame created for dim_counterparty.')
    except Exception as e:
        return e

    try:
        # Convert to Parquet File and write to S3 'transform' bucket:
        pq = df.to_parquet(
            f"s3://{bucket_name}/dim_counterparty.parquet", compression='gzip')
        return 'dim_counterparty added to S3'

    except Exception as e:
        return {'Status': 'dim_counterparty not added', 'message': str(e)}


def dim_currency(file):
    # Establish name of process Bucket:
    bucket_name = get_bucket_names()['process']
    # New Currency Dictionary:
    cur_list = []
    # Iterate through currency
    for currency in file['currency']:
        # Dictionary for currency code lookup:
        currency_code = {'GBP': 'British Pound',
                         'USD': 'US Dollar', 'EUR': 'Euros'}
        temp_dict = {
            # Convert ID to integer:
            'currency_id': int(currency['currency_id']),
            # Convert Code to String:
            'currency_code': str(currency['currency_code']),
            # Lookup Currency Code.  Convert to string:
            'currency_name': str(currency_code[currency['currency_code']])
        }
        # Append dictionary to list.
        cur_list.append(temp_dict)
        # Convert list into dataframe:
        df = pd.DataFrame(data=cur_list)
        try:
            # Write dataframe to S3 bucket as parquet file:
            pq = df.to_parquet(
                f"s3://{bucket_name}/dim_currency.parquet", compression='gzip')
        except Exception as e:
            return {'Status': 'dim_currency not added', 'message': str(e)}
    return df


# CALL FUNCTIONS HERE:
# parquet_location = './files/parquet/dim_counterparty.parquet'
# df_counterparty = pd.read_parquet(parquet_location)

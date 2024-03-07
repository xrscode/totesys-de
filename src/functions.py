import boto3
import json
from datetime import datetime
import awswrangler as wr
import logging


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


bucket_names = get_bucket_names()


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
    return datetime.strptime(str, '%Y-%m-%d %H:%M:%S.%f')


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
    Returns a json string with the latest data.\n
    ```
    This function will compare 'last_updated' fields to\n
    time stored in aws_parameter store.  If the last_updated time\n
    is ahead of aws_parameter store, it will pull\n
    that information out of the database. \n
    It is used to scan the database to find recently updated records.
    When it has finished, it will update the time in the aws_parameter store.
    """
    # Returns datetime object from last query time.
    last_query_time = get_aws_time().strftime('%Y-%m-%d %H:%M')
    table_dict = {'counterparty': None, 'currency': None,
                  'department': None, 'design': None,
                  'staff': None, 'sales_order': None,
                  'address': None, 'payment': None,
                  'purchase_order': None, 'payment_type': None,
                  'transaction': None}

    # Establish a connection to the PostgreSQL database
    con = wr.postgresql.connect(secret_id='new_tote')
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
    # update_aws_time(datetime.now())
    return json_str


def create_path_add_file(file, bucket_name=bucket_names['ingestion']):
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
                print(e)
                return 'Unable to create file path.'
    # File path exists, will now attempt to place
    # JSON object into the file path location.
    # Create a unique file name.
    file_name = f"{date_str}{current_time}.json"
    # Add file to the file location created earlier.
    s3.put_object(Body=file, Bucket=bucket_name, Key=file_name)
    # Update AWS Time
    update_aws_time(datetime.now())
    print(f"File path created: {date_str}.  File added!")
    return f"File path created: {date_str}.  File added!"


def return_one():
    return 1

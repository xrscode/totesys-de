from functions import *


def handler(event, context):
    try:
        # Access data from RDS Database:
        data = all_data()
    except Exception as e:
        return 'Error: {}'.format(e)
    try:
        # Adding data to S3 Ingestion bucket:
        create_path_add_file(data, bucket_name=get_bucket_names()['ingestion'])
        return 'Files added to S3 bucket.'
    except Exception as e:
        return 'Error: {}'.format(e)

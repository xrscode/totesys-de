from functions import *


def handler(event, context):
    try:
        data = all_data()
        create_path_add_file(data, bucket_name=get_bucket_names()['ingestion'])
    except Exception as e:
        return 'Error: {}'.format(e)

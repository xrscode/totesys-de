from functions import *


def handler(event, context):
    try:
        records = event['Records']
        bucket_process = get_bucket_names()['process']
        s3.put_object(Key=records, Bucket=bucket_process)
        return records

    except Exception as e:
        return 'Error: {}'.format(e)

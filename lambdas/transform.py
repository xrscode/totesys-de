from functions import *


def handler(event, context):
    try:
        records = event['Records']
        s3.put_object(Key=records, Bucket=get_bucket_names()['process'])

    except Exception as e:
        return 'Error: {}'.format(e)

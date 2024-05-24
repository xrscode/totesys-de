from functions import *
import logging
import json
import boto3


def handler(event, context):
    # Log Incomming event:
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.info("Received event: %s", json.dumps(event, indent=2))

    s3 = boto3.client('s3')

    try:
        # Save bucket name file is stored in:
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        # Save file name and location:
        file_key = event['Records'][0]['s3']['object']['key']
        # Save data from new file:
        data = json.loads(s3.get_object(
            Bucket=bucket_name, Key=file_key)['Body'].read())

    except Exception as e:
        return 'Error: {}'.format(e)

    # Attempt to create/update dim_counterparty:
    try:
        dim_counterparty(data)
    except Exception as e:
        return 'Error: {}'.format(e)

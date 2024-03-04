import boto3
import json


def get_bucket_names():
    """
    Args:
    ------
    None.

    Returns:
    ------
    Object containing names of S3 buckets.
    """
    s3 = boto3.client('s3')
    bucket_name = "terraform-xrs"
    object_key = "tf-state"
    response = s3.get_object(Bucket=bucket_name, Key=object_key)
    data = json.loads(response['Body'].read().decode(
        'utf-8'))['resources']
    bucket_obj = {}
    for instance in data:
        try:
            bucket_name = instance['instances'][0]['attributes']['bucket']
        except Exception as e:
            print(e)
            continue
        if bucket_name[0:9] == 'ingestion':
            bucket_obj['ingestion'] = bucket_name
        elif bucket_name[0:7] == 'process':
            bucket_obj['process'] = bucket_name
        elif bucket_name[0:7] == 'storage':
            bucket_obj['storage'] = bucket_name
    return bucket_obj

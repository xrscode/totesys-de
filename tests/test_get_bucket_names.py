from src.functions import *
import unittest
from unittest.mock import Mock, patch
from botocore.response import StreamingBody
import json


def test_returns_a_dictionary():
    invoke = isinstance(get_bucket_names(), dict)
    assert invoke == True

# Get Time
# def test_returns_a_datetime_object()
#     invoke = isinstance(aws_time(), datetime)
#     assert invoke == True


# @patch('src.functions.boto3.client')
# def test_returns_correct_dictionary(mock_boto3_client):
#     # Create a mock S3 client
#     mock_s3_client = mock_boto3_client.return_value
#     # Creats mock response
#     mock_s3_client.get_object.return_value = {
#         'Body': json.dumps({
#             "resources": [
#                 {"instances": [
#                     {"attributes": {"bucket": "ingestion-20240304201826545600000001"}}]},
#                 {"instances": [
#                     {"attributes": {"bucket": "process-20240304201826547200000003"}}]},
#                 {"instances": [
#                     {"attributes": {"bucket": "storage-20240304201826546800000002"}}]}
#             ]
#         }).encode('utf-8')
#     }
#     # Define the expected result
#     expected_result = {
#         'ingestion': 'ingestion-20240304201826545600000001',
#         'process': 'process-20240304201826547200000003',
#         'storage': 'storage-20240304201826546800000002'
#     }

#     # Call the function under test
#     result = get_bucket_names()

#     # Assert the result
#     assert True

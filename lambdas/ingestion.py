# from functions import *
from functions import *


def handler(event, context):
    names = get_bucket_names()
    date = get_aws_time()
    # data = all_data()
    return names

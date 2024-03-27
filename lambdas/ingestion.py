# from functions import *
from functions import *


def handler(event, context):
    date = get_secret()
    return date

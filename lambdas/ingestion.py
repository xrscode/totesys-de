# from functions import *
from src.functions import *


def handler(event, context):
    date = get_secret()
    return date

# Hello.

print(return_one())
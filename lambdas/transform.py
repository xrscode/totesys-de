from functions import *


def handler(event, context):
    try:
        return return_one()
    except Exception as e:
        return 'Error: {}'.format(e)

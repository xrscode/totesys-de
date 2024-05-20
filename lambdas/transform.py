from functions import *


def handler(event, context):
    try:
        return process_write(event)

    except Exception as e:
        return 'Error: {}'.format(e)

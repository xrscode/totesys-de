from functions import *


def handler(event):
    try:
        return process_write(event)

    except Exception as e:
        return 'Error: {}'.format(e)

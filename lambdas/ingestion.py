from functions import *

async def handler(event, context):
    try:
        await data = all_data()
        await create_path_add_file(data, bucket_name=get_bucket_names()['ingestion'])
    except:
        return 'Error!'

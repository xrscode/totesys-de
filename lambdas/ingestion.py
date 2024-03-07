from src.functions import *

# Scan Database and assemble JSON:
data = all_data()

# Upload to S3 Bucket:
create_path_add_file(data)

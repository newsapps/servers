PUT = 'your'
TEMPLATE = 'variables'
IN = 'here'

# Boot script template configs
SERVER_TYPES = {
    'newsapps/app-nginx.sh': 'app'
}

# Secrets should go in your config_local.py. Putting these here for reference.
ACCESS_KEY = 'aws access key id'
SECRET_KEY = 'aws secret key'
ASSET_BUCKET = 'bucket name here'

# Load overrides from config_local.py
try:
    from config_local import *
except:
    pass

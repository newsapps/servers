PUT = 'your'
TEMPLATE = 'variables'
IN = 'here'

# Boot script template configs
ASSET_BUCKET = 'bucket name here'
SERVER_TYPES = {
    'newsapps/app-nginx.sh': 'app'
}

# Load overrides from config_local.py
try:
    from config_local import *
except:
    pass

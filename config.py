PUT = 'your'
TEMPLATE = 'variables'
IN = 'here'

# Boot script template configs
SERVER_TYPES = {
    'newsapps/app-nginx.sh': 'app',
    'newsapps/app-cache.sh': 'app',
    'newsapps/app.sh': 'app',
    'newsapps/cron.sh': 'worker',
    'newsapps/db-nfs.sh': 'admin',
    'newsapps/lb.sh': 'lb',
    'newsapps/base.sh': 'none',
    'newsapps/kitchensink.sh': 'none',
    'newsapps/archive-worker.sh': 'worker',
}

# Secrets should go in your config_local.py. Putting these here for reference.
ACCESS_KEY = 'aws access key id'
SECRET_KEY = 'aws secret key'
ASSET_BUCKET = 'bucket name here'

# If you have a repo for secrets, it'll be cloned to ~/sites/secrets
# SECRETS_REPO = 'git@github.com:example/secrets.git'

# Load overrides from config_local.py
try:
    from config_local import *
except:
    pass

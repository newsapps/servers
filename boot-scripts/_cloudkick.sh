# Include file to setup cloudkick monitoring

# Add the cloudkick repo to apt
echo 'deb http://packages.cloudkick.com/ubuntu lucid main' > /etc/apt/sources.list.d/cloudkick.list
curl http://packages.cloudkick.com/cloudkick.packages.key | apt-key add -

# Get packages
apt-get update

# Create the config file
echo "oauth_key {{settings.cloudkick_oauth_key}}
oauth_secret {{settings.cloudkick_oauth_secret}}
tags {{server.cloudkick_tags}}
name {{server.name}}" > /etc/cloudkick.conf

# Install the monitor
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install cloudkick-agent

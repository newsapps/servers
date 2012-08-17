#!/bin/bash -x
{% block start %}
USERNAME=ubuntu
{% endblock %}

# Include functions
{% include "lib.sh" %}
echo "-------- Cloud Commander setup --------"

# echo commands to the console and stop on errors
echo 'Logging to /var/log/user-data.log ...'
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Make sure we have a locale defined
echo 'Setting locale ...'
export LANG="en_US.UTF-8"

# change ubuntu user to custom username
echo "Configuring '$USERNAME' user..."
if [ $USERNAME -a $USERNAME != 'ubuntu' ]; then
    usermod -l $USERNAME -d /home/$USERNAME -m ubuntu
    groupmod -n $USERNAME ubuntu

    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-cloudimg-$USERNAME
    chmod 0440 /etc/sudoers.d/90-cloudimg-$USERNAME
    rm /etc/sudoers.d/90-cloudimg-ubuntu

    sed "s/ubuntu/$USERNAME/g" </root/.ssh/authorized_keys >/root/.ssh/authorized_keys
fi

{% if server.name -%}
# configure hostname
echo "Configuring hostname as {{server.name}}..."
echo {{ server.name }} > /etc/hostname
hostname {{ server.name }}
{% endif -%}

# update the software
echo "Updating OS..."
export DEBIAN_FRONTEND=noninteractive
apt-get -q update && apt-get -q upgrade -y

# grab some basic utilities
install_pkg build-essential python-setuptools python-dev zip \
    git-core subversion unattended-upgrades mailutils \
    mdadm xfsprogs s3cmd python-pip python-virtualenv \
    virtualenvwrapper libxml2-dev libxslt-dev libgeos-dev \
    libpq-dev postgresql-client mysql-client libmysqlclient-dev \
    runit

# need an updated version of boto
easy_install --upgrade boto

echo "Setting up user environment..."

# Carry over AWS keys for s3cmd
echo "[default]
access_key = {{settings.access_key}}
secret_key = {{settings.secret_key}}" > /home/$USERNAME/.s3cfg

# Setup profile stuff
echo "export SECURITY_GROUP={{settings.security_group}}
export PRIVATE_KEY=/home/$USERNAME/.ssh/{{settings.key_pair}}.pem
export AWS_ACCESS_KEY_ID={{settings.access_key}}
export AWS_SECRET_ACCESS_KEY={{settings.secret_key}}
{% if server.cluster -%}
export CLUSTER={{server.cluster}}
{% endif -%}
" > /etc/profile.d/cloud-commander.sh
source /etc/profile

# Pull down assets
echo "Downloading assets..."
ASSET_DIR="/home/$USERNAME/cloud-commander"
s3cmd get --config=/home/$USERNAME/.s3cfg --no-progress s3://{{settings.asset_bucket}}/{{settings.cc_key}}-assets.tgz /home/$USERNAME/assets.tgz

cd /home/$USERNAME
tar -zxf assets.tgz

# fix asset permissions
chown -Rf root:root $ASSET_DIR
chmod -Rf 755 $ASSET_DIR

# install scripts
cp $ASSET_DIR/bin/* /usr/local/bin

# load private keys
cp $ASSET_DIR/*.pem /home/$USERNAME/.ssh/

# load authorized keys
if [ -f $ASSET_DIR/authorized_keys ]; then
    cat $ASSET_DIR/authorized_keys >> /home/$USERNAME/.ssh/authorized_keys
fi

# load known hosts
if [ -f $ASSET_DIR/known_hosts ]; then
    cp $ASSET_DIR/known_hosts /home/$USERNAME/.ssh/known_hosts
fi

# load ssh config
if [ -f $ASSET_DIR/ssh_config ]; then
    cp $ASSET_DIR/ssh_config /home/$USERNAME/.ssh/config
fi

# make sure ssh is set to start at boot
update-rc.d ssh enable 2345

# fix permissions in ssh folder
chmod -Rf go-rwx /home/$USERNAME/.ssh

# setup our local hosts file
/usr/local/bin/hosts-for-cluster

{% if settings.cloudkick_oauth_key -%}
{% include "_cloudkick.sh" %}
{% endif -%}

{% block install %}

{% endblock %}

echo "Cleaning up..."

# Fix any perms that might have gotten messed up
chown -Rf $USERNAME:$USERNAME /home/$USERNAME

# fix asset permissions
chown -Rf root:root $ASSET_DIR
chmod -Rf 755 $ASSET_DIR

# make sure our user is a member of the web group
usermod -a -G www-data $USERNAME

# Update CC status - remove instance booting semaphore from s3
s3cmd del --config=/home/$USERNAME/.s3cfg {{settings.assets_s3_url}}`ec2metadata --instance-id`._cc_

{% block finish %}{% endblock %}


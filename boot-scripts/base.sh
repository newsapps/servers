#!/bin/bash -x
{% block start %}
USERNAME=ubuntu
{% endblock %}

# Include functions
{% include "lib.sh" %}

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

{% if SERVER_NAME -%}
# configure hostname
echo "Configuring hostname as {{SERVER_NAME}}..."
echo {{ SERVER_NAME }} > /etc/hostname
hostname {{ SERVER_NAME }}
{% endif -%}

# update the software
echo "Updating OS..."
export DEBIAN_FRONTEND=noninteractive
apt-get -q update && apt-get -q upgrade -y

# grab some basic utilities
install_pkg build-essential python-setuptools python-dev zip \
    git subversion mercurial unattended-upgrades mailutils \
    libevent-dev \
    mdadm xfsprogs s3cmd python-pip python-virtualenv python-all-dev \
    virtualenvwrapper libxml2-dev libxslt1-dev libgeos-dev \
    libpq-dev postgresql-client mysql-client libmysqlclient-dev \
    runit libproj0 libproj-dev proj-bin libfreetype6-dev libjpeg-dev zlib1g-dev \
    libgdal1-dev libgraphicsmagick++1-dev libboost-python-dev imagemagick \
    enchant graphicsmagick python-pgmagick libtiff4-dev libtiff5-dev liblcms2-dev \
    libwebp-dev python-imaging

# need an updated version of boto
easy_install --upgrade boto

# Make PIL build correctly
sudo ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/
sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/

# Make old versions of GeoDjango work
sudo ln -s /usr/lib/libgdal1.7.0.so /usr/lib/libgdal.so

echo "Setting up user environment..."

# Carry over AWS keys for s3cmd
echo "[default]
access_key = {{ACCESS_KEY}}
secret_key = {{SECRET_KEY}}" > /home/$USERNAME/.s3cfg

# Setup profile stuff
echo "{% if CLUSTER -%}
export CLUSTER={{CLUSTER}}
{% endif -%}
{% if SECURITY_GROUP -%}
export SECURITY_GROUP={{SECURITY_GROUP}}
{% else -%}
export SECURITY_GROUP={{SECURITY_GROUP}}
{% endif -%}
export PRIVATE_KEY=/home/$USERNAME/.ssh/{{KEY_PAIR}}.pem
export AWS_ACCESS_KEY_ID={{ACCESS_KEY}}
export AWS_SECRET_ACCESS_KEY={{SECRET_KEY}}
" > /etc/profile.d/aws-creds.sh
source /etc/profile

# Pull down assets
echo "Downloading assets..."
ASSET_DIR="/home/$USERNAME/assets"
s3cmd get --config=/home/$USERNAME/.s3cfg --no-progress s3://{{ASSET_BUCKET}}/{{ASSET_KEY}} /home/$USERNAME/assets.tgz

cd /home/$USERNAME
tar -zxf assets.tgz
rm assets.tgz

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

# make sure our clocks are always on time
echo 'ntpdate ntp.ubuntu.com' > /etc/cron.daily/ntpdate
chmod +x /etc/cron.daily/ntpdate

# fix permissions in ssh folder
chmod -Rf go-rwx /home/$USERNAME/.ssh

# setup our local hosts file
/usr/local/bin/hosts-for-cluster

# setup logs
mkdir /home/$USERNAME/logs
chmod o+w /home/$USERNAME/logs

install_file newsapps /etc/logrotate.d/newsapps.conf

mkdir /home/$USERNAME/sites

{% if CLOUDKICK_OAUTH_KEY -%}
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
s3cmd del --config=/home/$USERNAME/.s3cfg s3://{{ASSET_BUCKET}}/`ec2metadata --instance-id`._cc_

{% if SECRETS_REPO -%}
sudo -u newsapps -i git clone {{ SECRETS_REPO }} /home/$USERNAME/sites/secrets
{% endif -%}

{% block finish %}
reboot
{% endblock %}

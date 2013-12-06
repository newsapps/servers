#!/bin/bash -x

USERNAME=newsapps


# Include functions
# Some useful bash functions

# install_file $from_bundle $file_path
# ex:
#   install_file newsapps /etc/memcached.conf
#
function install_file {
    echo "Installing '$2' from assets"
    cp /home/$USERNAME/cloud-commander/$1$2 $2
    chown root:root $2
    chmod 644 $2
}

# install_pkgs $pkg_name
function install_pkg {
    echo "Installing packages $*"
    DEBIAN_FRONTEND='noninteractive' \
    apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
            $*
}

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

# configure hostname
echo "Configuring hostname as test..."
echo test > /etc/hostname
hostname test
# update the software
echo "Updating OS..."
export DEBIAN_FRONTEND=noninteractive
apt-get -q update && apt-get -q upgrade -y

# grab some basic utilities
install_pkg build-essential python-setuptools python-dev zip \
    git-core subversion mercurial unattended-upgrades mailutils \
    libevent-dev \
    mdadm xfsprogs s3cmd python-pip python-virtualenv python-all-dev \
    virtualenvwrapper libxml2-dev libxslt-dev libgeos-dev \
    libpq-dev postgresql-client mysql-client libmysqlclient-dev \
    runit proj libfreetype6-dev libjpeg-dev zlib1g-dev \
    libgdal1-dev

# need an updated version of boto
easy_install --upgrade boto

# Make PIL build correctly
sudo ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/
sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/

echo "Setting up user environment..."

# Carry over AWS keys for s3cmd
echo "[default]
access_key = 
secret_key = " > /home/$USERNAME/.s3cfg

# Setup profile stuff
echo "export SECURITY_GROUP=
export PRIVATE_KEY=/home/$USERNAME/.ssh/.pem
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
" > /etc/profile.d/cloud-commander.sh
source /etc/profile

# Pull down assets
echo "Downloading assets..."
ASSET_DIR="/home/$USERNAME/cloud-commander"
s3cmd get --config=/home/$USERNAME/.s3cfg --no-progress s3://ct-server-assets/ /home/$USERNAME/assets.tgz

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

# make sure our clocks are always on time
echo 'ntpdate ntp.ubuntu.com' > /etc/cron.daily/ntpdate
chmod +x /etc/cron.daily/ntpdate

# fix permissions in ssh folder
chmod -Rf go-rwx /home/$USERNAME/.ssh

# setup our local hosts file
/usr/local/bin/hosts-for-cluster





echo "Cleaning up..."

# Fix any perms that might have gotten messed up
chown -Rf $USERNAME:$USERNAME /home/$USERNAME

# fix asset permissions
chown -Rf root:root $ASSET_DIR
chmod -Rf 755 $ASSET_DIR

# make sure our user is a member of the web group
usermod -a -G www-data $USERNAME

# Update CC status - remove instance booting semaphore from s3
s3cmd del --config=/home/$USERNAME/.s3cfg s3://ct-server-assets/`ec2metadata --instance-id`._cc_


reboot

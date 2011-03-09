{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        apache2 \
        php5 php5-mysql php5-gd php-pear libapache2-mod-php5 \
        mysql-client \
        postfix \
        portmap nfs-common

# enable mod_rewrite
a2enmod rewrite

mkdir /mnt/apps
echo 'nfs:/mnt/apps	/mnt/apps	nfs	defaults' >> /etc/fstab
mount /mnt/apps

ln -s /mnt/apps/sites /home/$USERNAME/sites

{% endblock %}

{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        apache2 \
        php5 php5-mysql php5-gd php-pear libapache2-mod-php5

# enable mod_rewrite
a2enmod rewrite

# Install apache config
cp /home/$USERNAME/cloud-commander/wordpress/etc/apache2/apache2.conf /etc/apache2/apache2.conf
chown root:root /etc/apache2/apache2.conf
chmod 644 /etc/apache2/apache2.conf


{% include "_nfs-client.sh" %}

{% endblock %}

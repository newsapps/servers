{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        apache2 \
        php5 php5-mysql php5-gd php-pear libapache2-mod-php5 php-apc php5-curl php5-memcache

# enable mod_rewrite
a2enmod rewrite

# disable deflate
a2dismod deflate

# Install apache config
install_file wordpress /etc/apache2/apache2.conf

reload apache2

{% include "_syslog-client.sh" %}

{% include "_nfs-client.sh" %}

{% endblock %}

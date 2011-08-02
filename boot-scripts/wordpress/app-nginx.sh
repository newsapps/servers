{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        php5 php5-mysql php5-gd php5-fpm php-pear php-apc php5-curl php5-memcache \
        memcached
# php5-cgi

# Install memcached, but disable it by default
service memcached stop
update-rc.d memcached disable 2345

# include the script to build nginx from source
{% include "_nginx.sh" %}

# Install nginx config
# cp -Rf /home/$USERNAME/cloud-commander/wordpress/etc/nginx /etc/nginx
# chown -R root:root /etc/nginx
# chmod -R 644 /etc/nginx

{% include "_syslog-client.sh" %}

{% include "_nfs-client.sh" %}

{% endblock %}

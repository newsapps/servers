{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        php5 php5-mysql php5-gd php5-fpm php-pear php-apc php5-curl php5-memcache \
        mysql-client \
        postfix

# include the script to build nginx from source
{% include "_nginx.sh" %}

# Install nginx config
install_file newsapps /etc/nginx/nginx.conf

# Install php-fpm config
install_file wordpress /etc/php5/fpm/pool.d/www.conf

{% include "_nfs-client.sh" %}

{% include "_syslog-server.sh" %}

{% endblock %}

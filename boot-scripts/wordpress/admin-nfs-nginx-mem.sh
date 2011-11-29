{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
install_pkg \
        php5 php5-mysql php5-gd php5-fpm php-pear php-apc php5-curl php5-memcache \
        mysql-client

# include the script to build nginx from source
{% include "_nginx.sh" %}

# Install php-fpm config
install_file wordpress /etc/php5/fpm/pool.d/www.conf

{% include "_nfs-server.sh" %}

{% include "_memcached.sh" %}

{% endblock %}

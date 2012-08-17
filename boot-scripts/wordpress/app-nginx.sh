{% extends 'wordpress/base.sh' %}

{% block install %}

# Install php-fpm config
install_file wordpress /etc/php5/fpm/pool.d/www.conf

# install nginx config
install_file wordpress /etc/nginx/nginx.conf

# install stuff
install_pkg php5 php5-mysql php5-gd php5-fpm php-pear php-apc php5-curl php5-memcache nginx-full

# reload it!
service php5-fpm restart
service nginx restart

{% include "_nfs-client.sh" %}

{% endblock %}

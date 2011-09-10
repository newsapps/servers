{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
install_pkg apache2 \
        php5 php5-mysql php5-gd php-pear libapache2-mod-php5 php-apc php5-curl \
        mysql-client \
        postfix

# enable mod_rewrite
a2enmod rewrite

# disable deflate
a2dismod deflate

# Install apache config
install_file wordpress /etc/apache2/apache2.conf

{% include "_nfs-client.sh" %}

{% include "_syslog-server.sh" %}

{% endblock %}

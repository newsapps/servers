{% extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
install_pkg apache2 \
        php5 php5-mysql php5-gd php-pear libapache2-mod-php5 php-apc php5-curl php5-memcache \
        mysql-client \
        postfix

# enable mod_rewrite
a2enmod rewrite

# disable deflate
a2dismod deflate

# Install apache config
cp /home/$USERNAME/cloud-commander/wordpress/etc/apache2/apache2.conf /etc/apache2/apache2.conf
chown root:root /etc/apache2/apache2.conf
chmod 644 /etc/apache2/apache2.conf

reload apache2

{% include "_syslog-server.sh" %}

# Needs a reboot -
{% include "_nfs-server.sh" %}

{% endblock %}

{% block finish %}
reboot
{% endblock %}

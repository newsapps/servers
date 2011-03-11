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
        postfix

# enable mod_rewrite
a2enmod rewrite

{% include "_nfs-client.sh" %}

{% endblock %}

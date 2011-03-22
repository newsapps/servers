{%extends 'wordpress/base.sh' %}

# we have to upgrade the kernel because the out of the box kernel
# on this particular ami ubuntu maverick doesn't support nfs. We'll
# do our standard setup without reloading the nfs config, then reboot.

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        mysql-server

# Needs a reboot -
{% include "_nfs-server.sh" %}

# MySQL configuration

# Comment out the bind-address config so MySQL will accept outside connections
sed "s/^bind-address/# bind-address/g" /etc/mysql/my.cnf >/etc/mysql/my.cnf.new
mv /etc/mysql/my.cnf.new /etc/mysql/my.cnf
#service mysql reload

# setup users for mysql
{% if settings.root_db_password -%}
echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY '{{settings.root_db_password}}' WITH GRANT OPTION;" |mysql

# set db root password
mysqladmin -u root password '{{settings.root_db_password}}'
{% else -%}
echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;" |mysql
{% endif -%}

{% endblock %}

{% block finish %}
reboot
{% endblock %}

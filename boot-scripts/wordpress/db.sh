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
        mysql-server \
        portmap nfs-common nfs-kernel-server \
        linux-image-virtual

# setup the directories for sharing, set permissions to the
# wordpress user and apache group, make the permissions sticky
mkdir /mnt/apps /mnt/apps/sites /mnt/apps/apache /mnt/apps/varnish
chown wordpress:www-data /mnt/apps/sites /mnt/apps/apache /mnt/apps/varnish
chmod ug+s /mnt/apps/sites /mnt/apps/apache

# Add our share to NFS exports
echo '/mnt/apps 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports

# Fix for NFSv4 that's sometimes needed for proper permissions
sed s/^NEED_IDMAPD=$/NEED_IDMAPD=yes/g /etc/default/nfs-common >/etc/default/nfs-common.new
mv /etc/default/nfs-common.new /etc/default/nfs-common
#service nfs-kernel-server reload

ln -s /mnt/apps/sites /home/$USERNAME/sites
ln -s /mnt/apps/apache /home/$USERNAME/apache
ln -s /mnt/apps/varnish /home/$USERNAME/varnish

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

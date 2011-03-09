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
mkdir /mnt/apps /mnt/apps/sites /mnt/apps/apache
chown wordpress:www-data /mnt/apps/sites /mnt/apps/apache
chmod ug+s /mnt/apps/sites /mnt/apps/apache

echo '/mnt/apps *(rw,sync,no_subtree_check)' >> /etc/exports
#service nfs-kernel-server reload

ln -s /mnt/apps/sites /home/$USERNAME/sites

{% endblock %}

{% block finish %}
reboot
{% endblock %}

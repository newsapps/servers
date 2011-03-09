{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        varnish \
        portmap nfs-common

mkdir /mnt/apps
echo 'nfs:/mnt/apps	/mnt/apps	nfs	defaults' >> /etc/fstab
mount /mnt/apps

ln -s /mnt/apps/varnish /home/$USERNAME/varnish

{% endblock %}

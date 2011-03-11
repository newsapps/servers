{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        varnish

{% include "_nfs-client.sh" %}

# Install varnish config file
cp /home/$USERNAME/cloud-commander/wordpress/etc/default/varnish /etc/default/varnish
chown root:root /etc/default/varnish
chmod 644 /etc/default/varnish
 


{% endblock %}

{%extends 'wordpress/base.sh' %}

{% block install %}
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        zip git-core subversion unattended-upgrades \
        build-essential \
        varnish

{% include "_syslog-client.sh" %}

{% include "_nfs-client.sh" %}

# Install varnish config file
cp $ASSET_DIR/wordpress/etc/default/varnish /etc/default/varnish
chown root:root /etc/default/varnish
chmod 644 /etc/default/varnish

# Configure varnish logging
echo "VARNISHNCSA_ENABLED=1" >> /etc/default/varnishncsa

cp $ASSET_DIR/wordpress/etc/init.d/varnishncsa /etc/init.d/varnishncsa
chown root:root /etc/init.d/varnishncsa
chmod 755 /etc/init.d/varnishncsa

# Start varnish logging
service varnishncsa start

{% endblock %}

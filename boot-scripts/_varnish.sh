
# install some basic stuff
DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        varnish

# Install varnish config file
install_file newsapps /etc/default/varnish

# Configure varnish logging
echo "VARNISHNCSA_ENABLED=1" >> /etc/default/varnishncsa

# Install varnish logging config file
install_file newsapps /etc/init.d/varnishncsa

# Start varnish logging
service varnishncsa start

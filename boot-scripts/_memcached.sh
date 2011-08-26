# Memcache Server setup

DEBIAN_FRONTEND='noninteractive' \
apt-get -q -y -o Dpkg::Options::='--force-confnew' install \
        memcached

install_file newsapps /etc/memcached.conf

service memcached restart

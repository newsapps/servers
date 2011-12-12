# Memcache Server setup

install_pkg memcached

install_file newsapps /etc/memcached.conf

service memcached restart

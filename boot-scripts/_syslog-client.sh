# Syslog is not great. It generates a lot of traffic that doesn't always
# make it to it's destination. It's probably best to just not use it.
# It works okay with a few servers. Def don't use syslog for http access logs.
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.d/99-newsapps.conf /etc/rsyslog.d/
service rsyslog restart

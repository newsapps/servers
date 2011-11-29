# Syslog is not great. It generates a lot of traffic that doesn't always
# make it to it's destination. It's probably best to just not use it.
# It works okay with a few servers. Def don't use syslog for http access logs.
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.conf /etc/rsyslog.conf
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.d/99-newsapps-admin.conf /etc/rsyslog.d/
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.d/50-default.conf /etc/rsyslog.d/
mkdir /var/log/apps
reload rsyslog

cp /home/$USERNAME/cloud-commander/newsapps/etc/logrotate.d/newsapps.conf /etc/logrotate.d/

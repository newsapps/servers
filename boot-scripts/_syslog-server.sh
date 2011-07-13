cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.conf /etc/rsyslog.conf
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.d/99-newsapps-admin.conf /etc/rsyslog.d/
cp /home/$USERNAME/cloud-commander/newsapps/etc/rsyslog.d/50-default.conf /etc/rsyslog.d/
mkdir /var/log/apps
reload rsyslog

cp /home/$USERNAME/cloud-commander/newsapps/etc/logrotate.d/newsapps.conf /etc/logrotate.d/

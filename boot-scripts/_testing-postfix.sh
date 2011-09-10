# Sets up a postfix server that reroutes all email to the local user account

# Need to set $MAIL_DOMAIN to what ever domain you will be sending from
if [ -z "${MAIL_DOMAIN+xxx}" ]; then MAIL_DOMAIN=example.com; fi

install_pkg postfix

echo "localhost :
$MAIL_DOMAIN :
* local:$USERNAME" > /etc/postfix/transport

postmap /etc/postfix/transport

echo "mynetworks = 10.0.0.0/8 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
transport_maps = hash:/etc/postfix/transport" >> /etc/postfix/main.cf

service postfix restart

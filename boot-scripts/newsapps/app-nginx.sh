{% extends 'newsapps/base.sh' %}

{% block install %}
# include the script to build nginx from source
install_pkg nginx-full
install_file newsapps /etc/nginx/nginx.conf

mkdir /home/$USERNAME/nginx
mkdir /mnt/nginx-cache
chmod ugo+rw /mnt/nginx-cache

service nginx restart

{% endblock %}

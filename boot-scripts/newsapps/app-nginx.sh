{% extends 'newsapps/base.sh' %}

{% block install %}
# include the script to build nginx from source
install_pkg nginx-full
install_file newsapps /etc/nginx/nginx.conf

service nginx restart

{% endblock %}

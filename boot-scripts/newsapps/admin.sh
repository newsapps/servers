{%extends 'wordpress/base.sh' %}

{% block install %}

# install some basic stuff
install_pkg postfix

{% include "_apache-python.sh" %}

{% include "_nfs-client.sh" %}

{% include "_syslog-server.sh" %}

{% endblock %}

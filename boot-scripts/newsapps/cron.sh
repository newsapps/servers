{%extends 'newsapps/base.sh' %}

{% block install %}

# install some basic stuff
install_pkg postfix

{% include "_nfs-client.sh" %}

{% include "_memcached.sh" %}

{% endblock %}

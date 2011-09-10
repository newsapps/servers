{% extends 'newsapps/base.sh' %}

{% block install %}

{% include '_syslog-client.sh' %}

{% include '_nfs-client.sh' %}

{% include '_apache-python.sh' %}

{% include '_memcached.sh' %}

{% endblock %}


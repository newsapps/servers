{% extends 'newsapps/base.sh' %}

{% block install %}

{% include '_postgres.sh' %}

{% include '_nfs-server.sh' %}

{% endblock %}

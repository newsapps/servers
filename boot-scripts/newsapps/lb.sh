{%extends 'newsapps/base.sh' %}

{% block install %}

{% include "_syslog-client.sh" %}

{% include "_nfs-client.sh" %}

{% include "_varnish.sh" %}

{% endblock %}

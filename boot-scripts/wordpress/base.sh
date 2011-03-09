{%extends 'base.sh'%}

{%block start %}
USERNAME=wordpress
{%endblock%}

{% block install %}
# install lamp stack
tasksel install lamp-server
echo "Please remember to set the MySQL root password!"
{% endblock %}


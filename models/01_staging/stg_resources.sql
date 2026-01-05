{% for source_db in var("project_evaluator_db") %}

  {% for source_schema in var("project_evaluator_schema") %}

    select * from {{ source_db }}.{{ source_schema }}.int_all_graph_resources

    {% if not loop.last %} union all {% endif %}

  {% endfor %}

{% endfor %}

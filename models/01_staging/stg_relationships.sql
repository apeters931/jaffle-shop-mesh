{% for source_db in var("project_evaluator_db") %}

  {% for source_schema in var("project_evaluator_schema") %}

    select
      *,
      split(parent_id, '.')[1] as parent_project_name,
      split(child_id, '.')[1] as child_project_name
    from {{ source_db }}.{{ source_schema }}.int_all_dag_relationships

    {% if not loop.last %} union all {% endif %}

  {% endfor %}

{% endfor %}
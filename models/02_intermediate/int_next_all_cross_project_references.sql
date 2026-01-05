-- current cross project references
with existing_cross_project_references as (
  select *
  from {{ ref('int_cross_project_references') }}
),

-- new relationships based on what you changed in your PR
current_project_all_dag_relationships as (
  select
    *,
    split(parent_id, '.')[1] as parent_project_name,
    split(child_id, '.')[1] as child_project_name
  from
    -- This runs against the model built within the current dbt run (ie. the PR's CI job)
    {{ ref('int_all_dag_relationships') }}
),

-- filter relationships just to cross project references
current_project_cross_project_references as (
  select *
  from current_project_all_dag_relationships
  where
    distance = 1
    and parent_project_name != child_project_name
),

-- filter out the current cross project references to just the project the PR is being opened in
existing_cross_project_references_without_current_project as (
  select *
  from existing_cross_project_references
  where child_project_name != '{{ project_name }}'
),

next_all_mesh_cross_project_references as (
  select
    parent_id,
    parent_project_name,
    child_id,
    child_project_name
  from existing_cross_project_references_without_current_project
  union all
  select
    parent_id,
    parent_project_name,
    child_id,
    child_project_name
  from current_project_cross_project_references
)

select
  parent_id,
  parent_project_name,
  child_id,
  child_project_name
from next_all_mesh_cross_project_references

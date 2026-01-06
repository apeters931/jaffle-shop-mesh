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
next_current_project_cross_project_references as (
  select *
  from current_project_all_dag_relationships
  where
    distance = 1
    and parent_project_name != child_project_name
    and child_project_name = '{{ project_name }}'
),

-- filter the current cross project references to just the project the PR is being opened in
existing_current_project_cross_project_references as (
  select *
  from existing_cross_project_references
  where child_project_name = '{{ project_name }}'
),

-- find cross project references that are now present in the PR that weren't in the current version
net_new_cross_project_references as (
  select next_current_project_cross_project_references.*
  from next_current_project_cross_project_references
  left join
    existing_current_project_cross_project_references
    using (parent_id, child_id)
  where existing_current_project_cross_project_references.parent_id is null
)
select * from net_new_cross_project_references

select *
from {{ ref('stg_relationships') }}
where
  -- only include cross project references
  distance = 1
  and parent_project_name != child_project_name

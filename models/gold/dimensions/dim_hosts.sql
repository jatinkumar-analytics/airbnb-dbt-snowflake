{{ config(materialized='table') }}

select
HOST_ID,
HOST_NAME,
IS_SUPERHOST,
RESPONSE_RATE_QUALITY,
HOST_SEGMENT,
HOST_SINCE

from {{ ref('snap_hosts_history') }}

qualify row_number() over(partition by HOST_ID order by dbt_valid_from desc)=1
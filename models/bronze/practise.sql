
{{ config(
    materialized='incremental',
    unique_key='listing_id'
) }}

select * 
from {{ ref('bronze_listings') }}

{% if is_incremental() %}
  where created_at > (select max(created_at) from {{ this }})
{% endif %}

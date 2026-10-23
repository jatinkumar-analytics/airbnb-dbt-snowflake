{{ config(materialized='table') }}

select
    listing_id,
    property_type,
    room_type,
    city,
    country,
    capacity_segment,
    price_per_night_tag

from {{ ref('snap_listings_history') }}

qualify row_number() over (partition by listing_id order by dbt_valid_from desc) = 1
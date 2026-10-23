{{
    config(
        materialized='incremental',
        unique_key='LISTING_ID',
        incremental_strategy='merge'
    )
}}

with latest_listings as (

    select *
    from {{ ref('bronze_listings') }}

    where listing_id is not null

    {% if is_incremental() %}
        and created_at >= (
            select coalesce(max(created_at), '1900-01-01')
            from {{ this }}
        )
    {% endif %}

    qualify row_number() over (
        partition by listing_id
        order by created_at desc
    ) = 1

)

select
    listing_id,
    host_id,

    initcap(trim(property_type)) as property_type,
    initcap(trim(room_type)) as room_type,
    initcap(trim(city)) as city,
    initcap(trim(country)) as country,

    accommodates,
    bedrooms,
    bathrooms,
    price_per_night,

    round(
        price_per_night / nullif(accommodates, 0),
        2
    ) as price_per_guest,

    case
        when price_per_night < 100 then 'BUDGET'
        when price_per_night < 200 then 'MID-RANGE'
        else 'PREMIUM'
    end as price_per_night_tag,

    case
        when accommodates <= 2 then 'SMALL'
        when accommodates <= 4 then 'MEDIUM'
        else 'LARGE'
    end as capacity_segment,

    case
        when host_id is null then 'MISSING_HOST'
        when price_per_night <= 0 then 'INVALID_PRICE'
        when accommodates <= 0 then 'INVALID_CAPACITY'
        else 'VALID'
    end as data_quality_status,

    created_at

from latest_listings
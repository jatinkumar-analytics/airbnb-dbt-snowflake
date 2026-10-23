{{config(
        materialized='incremental',
        unique_key='HOST_ID',
        incremental_strategy='merge'
    )}}

with latest_hosts as (

    select *
    from {{ ref('bronze_hosts') }}

    where host_id is not null

    {% if is_incremental() %}
        and created_at >= (
            select coalesce(max(created_at), '1900-01-01')
            from {{ this }}
        )
    {% endif %}

    qualify row_number() over (
        partition by host_id
        order by created_at desc
    ) = 1

)

select
    host_id,
    initcap(trim(host_name)) as host_name,
    host_since,
    is_superhost,
    response_rate,

    datediff(
        'year',
        host_since,
        cast(created_at as date)
    ) as host_tenure_years,

    case
        when response_rate >= 95 then 'EXCELLENT'
        when response_rate >= 90 then 'GOOD'
        when response_rate >= 80 then 'AVERAGE'
        else 'NEEDS IMPROVEMENT'
    end as response_rate_quality,

    case
        when is_superhost = true
             and response_rate >= 90
            then 'TOP PERFORMER'

        when is_superhost = true
            then 'SUPERHOST'

        when response_rate >= 90
            then 'HIGH RESPONSE HOST'

        else 'STANDARD HOST'
    end as host_segment,

    created_at

from latest_hosts
{{ config(materialized='table') }}

select
    b.booking_id,
    b.listing_id,
    sl.host_id,
    d.date_key,
    b.nights_booked,
    b.booking_amount,
    b.cleaning_fee,
    b.service_fee,
    b.booking_status,
    b.grand_total

from {{ ref('silver_bookings') }} b

left join {{ ref('silver_listings') }} sl
    on b.listing_id = sl.listing_id

left join {{ ref('dim_date') }} d
    on cast(b.booking_date as date) = d.date_day
{{ configs(materialized= 'ephemeral') }}

with bookings as
(select 
BOOKING_ID ,
BOOKING_STATUS,
BOOKING_CREATED_AT
from {{ ref(obt) }}
)
select * from bookings

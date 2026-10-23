select *
from {{ ref('silver_bookings') }}
where total_amount < 0
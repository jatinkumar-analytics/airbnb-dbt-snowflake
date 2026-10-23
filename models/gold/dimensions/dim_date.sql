
{{ config(materialized='table') }}

with date_bounds as
(
    select 
    min(cast(BOOKING_DATE as date)) as min_date,
    max(cast(BOOKING_DATE as date)) as max_date
    from {{ ref('silver_bookings') }}
 ),

 generate_date as
 (
    select dateadd(day,row_number() over(order by seq4()) -1 ,
    min_date) as date_day, max_date
    from date_bounds ,
    table(generator(rowcount=>10000))
    )

 select 
 to_number(to_char(date_day,'YYYYMMDD')) as date_key,
 date_day,
 YEAR(date_day) as year,
 quarter(date_day) as quarter,
 MONTH(date_day) as month,
 monthname(date_day) as month_name,
 dayname(date_day) as day_name

from generate_date
where date_day <= max_date


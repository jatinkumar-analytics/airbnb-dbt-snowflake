{{ config(materialized='table',
schema='gold')}}

{% set configs = [{
        "table": ref("silver_bookings"),
        "alias": "b",
        "columns": "
            b.BOOKING_ID,
            b.LISTING_ID,
            b.BOOKING_DATE,
            YEAR(b.BOOKING_DATE) AS BOOKING_YEAR,
            MONTH(b.BOOKING_DATE) AS BOOKING_MONTH,
            b.TOTAL_AMOUNT,
            b.ADDISSIONAL_FEE AS ADDITIONAL_FEE,
            b.GRAND_TOTAL,
            b.BOOKING_STATUS,
            b.CREATED_AT AS BOOKING_CREATED_AT
        "
    },

    {
        "table": ref("silver_listings"),
        "alias": "l",
        "columns": "
            l.HOST_ID,
            l.PROPERTY_TYPE,
            l.ROOM_TYPE,
            l.CITY,
            l.COUNTRY,
            l.ACCOMMODATES,
            l.BEDROOMS,
            l.BATHROOMS,
            l.PRICE_PER_NIGHT,
            l.PRICE_PER_GUEST,
            l.PRICE_PER_NIGHT_TAG,
            l.CAPACITY_SEGMENT,
            l.DATA_QUALITY_STATUS AS LISTING_DATA_QUALITY_STATUS,
            l.CREATED_AT AS LISTING_CREATED_AT
        ",
        "join_condition": "b.LISTING_ID = l.LISTING_ID"
    },

    {
        "table": ref("silver_hosts"),
        "alias": "h",
        "columns": "
            h.HOST_NAME,
            h.HOST_SINCE,
            h.IS_SUPERHOST,
            h.RESPONSE_RATE,
            h.HOST_TENURE_YEARS,
            h.RESPONSE_RATE_QUALITY,
            h.HOST_SEGMENT,
            h.CREATED_AT AS HOST_CREATED_AT
        ",
        "join_condition": "l.HOST_ID = h.HOST_ID"
    }

] %}
select {%- for items in configs -%}
        {{ items["columns"] }} {%- if not loop.last -%},{%- endif -%}
        {%- endfor -%}

        
        from {{ configs[0]["table"] }} as {{ configs[0]["alias"] }}

            {% for item in configs %}

             {% if not loop.first %}

        left join {{ item["table"] }} as {{ item["alias"] }}
            on {{ item["join_condition"] }}

    {% endif %}

{% endfor %}





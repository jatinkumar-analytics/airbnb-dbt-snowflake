# Airbnb Analytics — dbt + Snowflake

End-to-end dbt project that turns 5,700 rows of raw Airbnb data into a tested
star schema on Snowflake.

**Stack:** Snowflake · dbt Core · SQL · Jinja

---

## The pipeline

```
staging.bookings → bronze_booking  → silver_bookings ─┬→ fact_bookings
staging.listings → bronze_listings → silver_listings ─┼→ dim_listings
staging.hosts    → bronze_hosts    → silver_hosts ────┴→ dim_hosts
```

| Layer | What it does |
|---|---|
| **Bronze** | 1:1 copy of the raw source tables. No logic. |
| **Silver** | Cleaning, deduplication, calculated columns. |
| **Snapshots** | Keeps old listing and host values when they change. |
| **Gold** | Star schema — 3 dimensions + 1 fact table. |

---

## Models

| Model | Layer | What it does |
|---|---|---|
| `bronze_booking` | bronze | 5,000 raw bookings |
| `bronze_listings` | bronze | 500 raw listings |
| `bronze_hosts` | bronze | 200 raw hosts |
| `silver_bookings` | silver | Calculates `total_amount` and `grand_total` |
| `silver_listings` | silver | Latest row per listing, name casing, `price_per_guest`, price and capacity bands, `data_quality_status` |
| `silver_hosts` | silver | Latest row per host, `host_tenure_years`, `host_segment` |
| `dim_listings` | gold | One row per listing |
| `dim_hosts` | gold | One row per host |
| `dim_date` | gold | One row per day |
| `fact_bookings` | gold | Booking grain — keys + measures |

`fact_bookings` holds `listing_id`, `host_id`, `date_key` and the measures
`nights_booked`, `booking_amount`, `cleaning_fee`, `service_fee`, `grand_total`.

Duplicate listings are removed by keeping the newest row per listing:

```sql
qualify row_number() over (
    partition by listing_id
    order by created_at desc
) = 1
```

---

## Data quality — 40 tests

- `unique` + `not_null` on every primary key across bronze, silver and gold
- `relationships` tests from `fact_bookings` to all three dimensions
- `not_null` on `grand_total`
- A custom test that fails if any booking amount is negative

The raw data is never edited by hand. Bad rows are flagged in
`data_quality_status` inside `silver_listings`, so they can be filtered
downstream instead of being lost.

---

## Results

| Metric | Value |
|---|---|
| Records processed | 5,700 |
| dbt models | 11 |
| dbt tests | 40 |
| Snapshots (SCD2) | 2 |
| Gold tables | 4 (3 dimensions + 1 fact) |

---

*Jatin Kumar · [jatinanalytics.co.in](https://jatinanalytics.co.in) · [Full case study](https://jatinanalytics.co.in/airbnb-analytics-engineering.html)*

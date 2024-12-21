WITH
sessions_lc AS (
  SELECT *,
    CASE 
      WHEN gclid IS NOT NULL THEN "google"
      WHEN utm_source IS NOT NULL THEN utm_source
      WHEN referrer_hostname IS NOT NULL THEN 
        CASE
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'CHANGE_YOUR_DOMAIN.') THEN NULL -- your domain
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'klarna') THEN NULL -- referral exclusion payment providers
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'google.') THEN 'google'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'bing.') THEN 'bing'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'accounts.google.com') THEN NULL -- referral exclusion 
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'yahoo.') THEN 'yahoo'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'baidu.') THEN 'baidu'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'duckduckgo.') THEN 'duckduckgo'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'googlesyndication.com') THEN 'google'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'facebook.') THEN 'facebook'
          WHEN CONTAINS_SUBSTR(referrer_hostname, 'instagram.') THEN 'instagram'
          ELSE referrer_hostname
        END
      ELSE NULL
    END AS source,
    CASE 
      WHEN gclid IS NOT NULL THEN "cpc"
      WHEN utm_medium IS NOT NULL THEN utm_medium
      WHEN utm_source IS NOT NULL THEN "utm_source is defined but utm_medium is not"
      WHEN referrer_hostname IS NOT NULL THEN 
        CASE
          WHEN referrer_hostname LIKE '%CHANGE_YOUR_DOMAIN.%' THEN NULL -- your domain
          WHEN referrer_hostname LIKE '%adeyn%' THEN NULL -- referral exclusion payment providers
          WHEN referrer_hostname LIKE '%accounts.google.com%' THEN NULL -- referral exclusion 
          WHEN REGEXP_CONTAINS(referrer_hostname, r'google\.|bing\.|duckduckgo\.|yahoo\.|baidu\.') THEN 'organic'
          WHEN referrer_hostname LIKE '%facebook.%' THEN "social"
          ELSE 'referral'
        END
      ELSE NULL
    END AS medium
  FROM(
    SELECT *, 
    REGEXP_EXTRACT(page_location, r'^(?:https?://)?([^/]+)') AS hostname,
    IFNULL(REGEXP_EXTRACT(page_location, r'^(?:https?://)?[^/]+(/[^?]*)'), '/') AS lp,
    REGEXP_EXTRACT(page_referrer, r'^(?:https?://)?([^/]+)') AS referrer_hostname,
    REGEXP_EXTRACT(page_location, r'[?&]utm_source=([^&]+)') AS utm_source,
    REGEXP_EXTRACT(page_location, r'[?&]utm_medium=([^&]+)') AS utm_medium,
    REGEXP_EXTRACT(page_location, r'[?&]utm_campaign=([^&]+)') AS utm_campaign,
    REGEXP_EXTRACT(page_location, r'[?&]utm_term=([^&]+)') AS utm_term,
    REGEXP_EXTRACT(page_location, r'[?&]utm_content=([^&]+)') AS utm_content,
    REGEXP_EXTRACT(page_location, r'[?&]gclid=([^&]+)') AS gclid
    FROM(
      SELECT 
        event_date,
        event_timestamp,
        user_pseudo_id,
        (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') || "_" || user_pseudo_id as real_session_id,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') as page_location,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_referrer') as page_referrer,
        device.category AS device_category,
        geo.country,
        geo.region,
        geo.city,
        (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number')
      FROM `project.analytics_id.events_20*`
      WHERE event_name = 'session_start'
        AND PARSE_DATE('%y%m%d', _table_suffix) BETWEEN '2024-01-01' and CURRENT_DATE()
    )
  )
),

sessions_lnd AS 
(
SELECT *,
  IFNULL(LAST_VALUE(source IGNORE NULLS) OVER (lnd), "(direct)") AS source_lnd,
  IFNULL(LAST_VALUE(medium IGNORE NULLS) OVER (lnd), "(none)") AS medium_lnd,
  IFNULL(LAST_VALUE(gclid IGNORE NULLS) OVER (lnd), "(none)") AS gclid_lnd
FROM sessions_lc
WINDOW lnd AS (PARTITION BY user_pseudo_id ORDER BY event_timestamp ROWS BETWEEN 2592000000000 PRECEDING AND CURRENT ROW)),



conv AS (
  SELECT  
    event_date AS transaction_date,
    event_timestamp AS transaction_timestamp,
    user_pseudo_id,
    ecommerce.transaction_id AS transaction_id,
    ecommerce.purchase_revenue AS purchase_revenue,
    LAG(event_timestamp) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp) AS previous_event_timestamp
  FROM 
    `project.analytics_id.events_20*`
  WHERE 
    event_name = "purchase"
    --AND PARSE_DATE("%y%m%d", _table_suffix) BETWEEN "2024-01-01" AND CURRENT_DATE()
  ORDER BY 
    transaction_timestamp
), 

base AS

(SELECT
  conv.*,
  s.source || " / " || s.medium AS sm, 
  s.event_timestamp AS time,
  MIN(s.event_timestamp) OVER (PARTITION BY s.user_pseudo_id) AS first_touch
FROM 
  conv
LEFT JOIN 
  sessions_lnd s
  ON conv.user_pseudo_id = s.user_pseudo_id
    AND conv.transaction_timestamp > s.event_timestamp
    AND TIMESTAMP_MICROS(s.event_timestamp) > TIMESTAMP_SUB(TIMESTAMP_MICROS(conv.transaction_timestamp), INTERVAL 30 DAY)
    AND (conv.previous_event_timestamp < s.event_timestamp OR conv.previous_event_timestamp IS NULL)
ORDER BY 
  transaction_id, s.event_timestamp)



SELECT  
  transaction_date,
  transaction_timestamp,
  first_touch,
  user_pseudo_id,
  transaction_id,
  purchase_revenue,
  STRING_AGG(sm, " > " ORDER BY time) AS sm
FROM 
 base
 GROUP BY 
  1, 2, 3, 4, 5, 6

-- Databricks notebook source
SELECT*
FROM brightlearn_tv.bright_tv.user_profile
LIMIT 10;

-- checking for duplicates in my data
SELECT UserID,
COUNT(*) AS duplicate_count
FROM brightlearn_tv.bright_tv.user_profile
GROUP BY UserID
HAVING COUNT(*) > 1;

-- I am checking the size pf the data
SELECT COUNT(*) AS number_of_rows,
COUNT(DISTINCT UserID) AS number_subs
FROM brightlearn_tv.bright_tv.user_profile;

-- Are the any rows where useRID is NULL
SELECT COUNT(*) AS cnt
FROM brightlearn_tv.bright_tv.user_profile
WHERE UserID IS NULL;

SELECT DISTINCT UserID
FROM brightlearn_tv.bright_tv.user_profile;

---------------------------------------------------------
--Gender Checks
---------------------------------------------------------
SELECT DISTINCT gender
FROM brightlearn_tv.bright_tv.user_profile;

SELECT COUNT(*) 
FROM brightlearn_tv.bright_tv.user_profile
WHERE TRIM(gender) = '';

SELECT
COUNT(DISTINCT userid) AS subs,
CASE
WHEN TRIM(gender) ='' THEN 'None'
ELSE gender
END AS Gender
FROM brightlearn_tv.bright_tv.user_profile
GROUP BY Gender;

---------------------------------------------------------
--Race Checks
---------------------------------------------------------
SELECT COUNT(*) AS num_rows
FROM brightlearn_tv.bright_tv.user_profile
WHERE Race IS NULL;

SELECT DISTINCT Race
FROM brightlearn_tv.bright_tv.user_profile;

Select DISTINCT
CASE
WHEN Race = 'other' THEN 'None'
WHEN TRIM(Race) = '' THEN 'None'
ELSE Race
END AS Race
FROM brightlearn_tv.bright_tv.user_profile;

SELECT
COUNT(DISTINCT UserID) AS subs,
CASE
WHEN Race='other' THEN 'None'
WHEN Race=' ' THEN 'None'
ELSE Race
END AS Race
FROM brightlearn_tv.bright_tv.user_profile
GROUP BY race;

SELECT COUNT(*) AS total
FROM brightlearn_tv.bright_tv.user_profile
WHERE race = 'None';

---------------------------------------------------------
--Province Checks
---------------------------------------------------------
SELECT DISTINCT Province
FROM brightlearn_tv.bright_tv.user_profile;

SELECT DISTINCT
CASE
WHEN Province=' ' THEN 'Uncategorized'
WHEN Province='None' THEN 'Uncategorized'
ELSE Province
END AS Region
FROM brightlearn_tv.bright_tv.user_profile;

SELECT COUNT(DISTINCT UserID) AS subs,
CASE
WHEN Province=' ' THEN 'Uncategorized'
WHEN Province='None' THEN 'Uncategorized'
ELSE Province
END AS Region
FROM brightlearn_tv.bright_tv.user_profile
GROUP BY Province;

---------------------------------------------------------
--Age
---------------------------------------------------------
SELECT MIN(Age) AS min_age, 
MAX(Age) AS max_age 
FROM brightlearn_tv.bright_tv.user_profile;

SELECT COUNT(*) AS cnt
FROM brightlearn_tv.bright_tv.user_profile
WHERE age IS NULL;

SELECT *
FROM brightlearn_tv.bright_tv.viewership
LIMIT 10;

SELECT
    `Duration 2`,
    typeof(`Duration 2`) AS data_type
FROM brightlearn_tv.bright_tv.viewership
LIMIT 10;

WITH user_profiles AS (
  SELECT
    UserID,
    CASE
      WHEN Gender = 'None' THEN 'unknown'
      WHEN Gender = ' ' THEN 'unknown'
      WHEN Gender IS NULL THEN 'unknown'
      ELSE Gender
    END AS Sex,
    CASE
      WHEN Race = 'None' THEN 'unknown'
      WHEN Race = ' ' THEN 'unknown'
      WHEN Race = 'other' THEN 'unknown'
      WHEN Race IS NULL THEN 'unknown'
      ELSE Race
    END AS Ethnicity,
    CASE
      WHEN Age = 0 THEN 'infant'
      WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
      WHEN Age BETWEEN 13 AND 17 THEN 'youth'
      WHEN Age BETWEEN 18 AND 35 THEN 'youth Adults'
      WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
      WHEN Age > 50 AND Age <= 60 THEN 'Elder'
      WHEN Age > 60 THEN 'Pensioner'
    END AS Age_group,
    CASE
      WHEN Province = 'None' THEN 'Unclassified'
      WHEN Province = ' ' THEN 'Unclassified'
      WHEN Province = 'other' THEN 'Unclassified'
      WHEN Province IS NULL THEN 'Unclassified'
      ELSE Province
    END AS Regions,
    CASE
      WHEN Email IS NOT NULL THEN 1
      WHEN Email <> ' ' THEN 1
      ELSE 0
    END AS Email_flag,
    CASE
      WHEN `Social Media Handle` IS NOT NULL THEN 1
      ELSE 0
    END AS Social_media_handle_flag
  FROM brightlearn_tv.bright_tv.user_profile
),
Base_viewership AS (
  SELECT
    COALESCE(UserID0, userid4) AS User_id,
    FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,
    Channel2,
    `Duration 2`
  FROM brightlearn_tv.bright_tv.viewership
),
Cleaned_viewership AS (
  SELECT
    User_id,
    RecordDate_SAST,
    TO_DATE(RecordDate_SAST) AS watch_date,
    DAYNAME(TO_DATE(RecordDate_SAST)) AS day_name,
    DATE_FORMAT(TO_DATE(RecordDate_SAST), 'MMMM') AS month_name,
    YEAR(TO_DATE(RecordDate_SAST)) AS event_year,
    DAY(TO_DATE(RecordDate_SAST)) AS event_day,
    HOUR(RecordDate_SAST) AS Hour_of_day,
    CASE
      WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat', 'Sun') THEN '02. Weekend'
      ELSE '01. Weekday'
    END AS day_classification,
    DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') AS watch_time,
    CASE
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
      WHEN DATE_FORMAT(RecordDate_SAST, 'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS Time_of_day,
    `Duration 2`,
    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,
    (
      HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) +
      MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 +
      SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 3600.0
    ) AS Duration_hours,
    (
      HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
      MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
      SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
    ) AS Duration_seconds,
    CASE
      WHEN (
        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
      ) BETWEEN 300 AND 1800 THEN '01. Low Usage (<30 min)'
      WHEN (
        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
      ) BETWEEN 1801 AND 3599 THEN '02. Medium Usage (<60 min)'
      WHEN (
        HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 +
        MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 +
        SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
      ) >= 3600 THEN '03. High Usage (>60 min)'
      ELSE '04. No Usage'
    END AS Screen_time_bucket,
    CASE
      WHEN Channel2 IN ('SawSee', 'Sawsee') THEN 'SawSee'
      WHEN Channel2 IN ('SuperSport Live Events', 'Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
      ELSE Channel2
    END AS Tv_channel
  FROM Base_viewership
)
SELECT
  COALESCE(A.User_id, B.UserID) AS Sub_ID,
  Sex,
  Ethnicity,
  Age_group,
  Regions,
  Email_flag,
  Social_media_handle_flag,
  RecordDate_SAST,
  watch_date,
  day_name,
  month_name,
  event_year,
  event_day,
  Hour_of_day,
  day_classification,
  watch_time,
  Time_of_day,
  Duration,
  Duration_hours,
  Duration_seconds,
  Screen_time_bucket,
  Tv_channel
FROM Cleaned_viewership AS A
LEFT JOIN user_profiles AS B
ON A.User_id = B.UserID;

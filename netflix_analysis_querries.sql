-- ***********************************************************************************
-- * Section 4: Analysis Queries                                                   *
-- ***********************************************************************************

USE netflix_analysis;

-- A. Basic Exploration

-- 1. How many unique titles are in the dataset?
SELECT COUNT(DISTINCT title) AS unique_titles_count
FROM netflix_titles;

-- 2. How many are Movies and how many are TV Shows?
SELECT type, COUNT(*) AS count
FROM netflix_titles
GROUP BY type;

-- 3. What is the average rating of all shows?
-- Since 'rating' is numerical in your data, a direct AVG() is meaningful.
SELECT AVG(rating) AS average_rating
FROM netflix_titles
WHERE rating IS NOT NULL;


-- B. Filtering & Grouping

-- 1. Which genre has the highest number of titles?
SELECT genre, COUNT(*) AS title_count
FROM netflix_titles
WHERE genre IS NOT NULL AND genre != ''
GROUP BY genre
ORDER BY title_count DESC
LIMIT 1;

-- 2. Which country has produced the most Netflix content?
SELECT country, COUNT(*) AS content_count
FROM netflix_titles
WHERE country IS NOT NULL AND country != ''
GROUP BY country
ORDER BY content_count DESC
LIMIT 1;

-- 3. Which 5 years had the most releases?
SELECT release_year, COUNT(*) AS release_count
FROM netflix_titles
GROUP BY release_year
ORDER BY release_count DESC
LIMIT 5;


-- C. Date Analysis

-- 1. How many shows were added each year?
SELECT YEAR(added_to_netflix) AS added_year, COUNT(*) AS shows_added_count
FROM netflix_titles
WHERE added_to_netflix IS NOT NULL
GROUP BY added_year
ORDER BY added_year;


-- D. Advanced Aggregations

-- 1. What’s the average cast count for each genre?
-- Uses the 'cast_count' column directly from your CSV.
SELECT genre, AVG(cast_count) AS average_cast_count
FROM netflix_titles
WHERE genre IS NOT NULL AND genre != '' AND cast_count IS NOT NULL
GROUP BY genre
ORDER BY average_cast_count DESC;

-- 2. What’s the highest-rated show in each country?
-- Uses the numerical 'rating' column.
SELECT
    t1.country,
    t1.title,
    t1.rating
FROM
    netflix_titles t1
JOIN (
    SELECT
        country,
        MAX(rating) AS max_rating
    FROM
        netflix_titles
    WHERE country IS NOT NULL AND country != '' AND rating IS NOT NULL
    GROUP BY
        country
) AS t2
ON t1.country = t2.country AND t1.rating = t2.max_rating
ORDER BY t1.country, t1.title;


-- E. Window Functions Practice

-- 1. Rank all shows by rating within each country.
-- Ranking is based on numerical 'rating'.
SELECT
    country,
    title,
    rating,
    RANK() OVER (PARTITION BY country ORDER BY rating DESC) AS rank_by_rating
FROM
    netflix_titles
WHERE country IS NOT NULL AND country != '' AND rating IS NOT NULL
ORDER BY country, rank_by_rating;

-- 2. Find the running total of titles added to Netflix per year.
SELECT
    YEAR(added_to_netflix) AS added_year,
    COUNT(*) AS titles_added_this_year,
    SUM(COUNT(*)) OVER (ORDER BY YEAR(added_to_netflix)) AS running_total_titles
FROM
    netflix_titles
WHERE added_to_netflix IS NOT NULL
GROUP BY
    added_year
ORDER BY
    added_year;


-- F. Bonus Challenge

-- 1. Identify the country whose TV Shows have the highest average rating.
-- Uses the numerical 'rating' directly for average calculation.
SELECT
    country,
    AVG(rating) AS average_rating
FROM
    netflix_titles
WHERE
    type = 'TV Show' AND country IS NOT NULL AND country != '' AND rating IS NOT NULL
GROUP BY
    country
ORDER BY
    average_rating DESC
LIMIT 1;

-- 2. Which genre has the most diverse language usage?
-- Uses the 'language' column directly from your CSV.
SELECT
    genre,
    COUNT(DISTINCT language) AS unique_languages_count
FROM
    netflix_titles
WHERE genre IS NOT NULL AND genre != '' AND language IS NOT NULL AND language != ''
GROUP BY
    genre
ORDER BY
    unique_languages_count DESC
LIMIT 1;
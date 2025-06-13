-- ***********************************************************************************
-- * Diagnostic Queries to troubleshoot empty results                                *
-- * Run these in a new SQL tab after using 'USE netflix_analysis;'                 *
-- ***********************************************************************************

USE netflix_analysis;

-- 1. Check if any data exists in the table at all:
--    Expected: A count greater than 0 (e.g., 30 from your CSV).
SELECT COUNT(*) AS total_rows_in_table
FROM netflix_titles;

-- 2. Look at a sample of the data (first 10 rows):
--    Expected: Your actual Netflix data rows, to visually inspect content and formats.
SELECT *
FROM netflix_titles
LIMIT 10;

-- 3. Check the 'added_to_netflix' column's status (after conversion):
--    3a. Show a sample of converted dates and their counts.
--        Expected: Dates should be in 'YYYY-MM-DD' format.
SELECT added_to_netflix, COUNT(*) AS date_count
FROM netflix_titles
WHERE added_to_netflix IS NOT NULL
GROUP BY added_to_netflix
ORDER BY added_to_netflix
LIMIT 10;

--    3b. Check if there are any NULL values in 'added_to_netflix'.
--        Expected: 0 rows, if all dates were successfully converted or handled.
SELECT COUNT(*) AS null_added_to_netflix_count
FROM netflix_titles
WHERE added_to_netflix IS NULL;

-- 4. Check the 'type' column for 'TV Show' entries specifically:
--    4a. See all distinct values in the 'type' column.
--        Expected: 'Movie', 'TV Show' (and possibly others if your data has them).
SELECT DISTINCT type
FROM netflix_titles;

--    4b. Count how many rows are categorized as 'TV Show'.
--        Expected: A count reflecting actual TV Shows in your data.
SELECT COUNT(*) AS tv_show_count
FROM netflix_titles
WHERE type = 'TV Show';

-- 5. Check 'country', 'genre', and 'language' columns for non-empty values:
--    These queries help ensure the data isn't empty or full of whitespace,
--    which could cause WHERE clauses to fail.
--    5a. Distinct countries:
SELECT DISTINCT country
FROM netflix_titles
WHERE country IS NOT NULL AND TRIM(country) != ''
LIMIT 10;

--    5b. Distinct genres:
SELECT DISTINCT genre
FROM netflix_titles
WHERE genre IS NOT NULL AND TRIM(genre) != ''
LIMIT 10;

--    5c. Distinct languages:
SELECT DISTINCT language
FROM netflix_titles
WHERE language IS NOT NULL AND TRIM(language) != ''
LIMIT 10;

-- 6. Check 'rating' column distribution:
--    Ensures numerical ratings are present and not NULL.
SELECT rating, COUNT(*) AS rating_count
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating
LIMIT 10;
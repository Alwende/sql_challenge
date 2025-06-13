-- ***********************************************************************************
-- * Section 3: Post-Import Data Type Conversion and Derived Columns             *
-- ***********************************************************************************

USE netflix_analysis;

-- Step 3.1: Clean up any truly empty or whitespace-only 'added_to_netflix' strings to NULL.
-- This prevents conversion errors on invalid date strings.
UPDATE netflix_titles
SET added_to_netflix = NULL
WHERE TRIM(added_to_netflix) = '';

-- Step 3.2: Now, modify the column from VARCHAR to DATE type.
-- MySQL can now seamlessly convert 'YYYY-MM-DD' formatted strings (or NULLs) to DATE type.
ALTER TABLE netflix_titles
MODIFY COLUMN added_to_netflix DATE;

-- Step 3.4: Create and populate the 'content_era' derived column.
-- Classifies content as "Old" (before 2015) or "Modern" (2015 and after).
ALTER TABLE netflix_titles ADD COLUMN content_era VARCHAR(10);
UPDATE netflix_titles
SET content_era = CASE
                    WHEN release_year < 2015 THEN 'Old'
                    ELSE 'Modern'
                  END;

-- Step 3.5: Create and populate 'duration_minutes' and 'duration_seasons' derived columns.
-- Extracts numerical values from the 'duration' string.
-- Uses TRIM() and LOWER() for robustness against spaces and case variations.
ALTER TABLE netflix_titles ADD COLUMN duration_minutes INT;
ALTER TABLE netflix_titles ADD COLUMN duration_seasons INT;
UPDATE netflix_titles
SET
    duration_minutes = CASE
                        WHEN TRIM(LOWER(duration)) LIKE '%min%' THEN CAST(REPLACE(TRIM(LOWER(duration)), ' min', '') AS UNSIGNED)
                        ELSE NULL
                       END,
    duration_seasons = CASE
                        WHEN TRIM(LOWER(duration)) LIKE '%season%' THEN CAST(REPLACE(REPLACE(TRIM(LOWER(duration)), ' seasons', ''), ' season', '') AS UNSIGNED)
                        ELSE NULL
                       END;
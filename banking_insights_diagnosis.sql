-- ***********************************************************************************
-- Section 2: Post-Import Data Type Conversion (Run AFTER all CSVs are imported)
-- ***********************************************************************************

USE banking_insights;

-- Convert 'is_active' column in 'accounts' from VARCHAR to BOOLEAN.
-- This handles the 'TRUE'/'FALSE' strings imported into the VARCHAR column.
UPDATE accounts
SET is_active = CASE
    WHEN LOWER(TRIM(is_active)) = 'true' THEN TRUE
    WHEN LOWER(TRIM(is_active)) = 'false' THEN FALSE
    ELSE NULL -- Set to NULL for any values that are not 'true' or 'false'
END
WHERE is_active IS NOT NULL;

ALTER TABLE accounts
MODIFY COLUMN is_active BOOLEAN;
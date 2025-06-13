-- ***********************************************************************************
-- * Section 1: Database and Table Creation                                      *
-- ***********************************************************************************

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS netflix_analysis;

-- Use the newly created or existing database
USE netflix_analysis;

-- Drop the table if it already exists to ensure a clean start
-- This is useful if you are re-running the script to start fresh.
DROP TABLE IF EXISTS netflix_titles;

-- Create the 'netflix_titles' table with columns matching your CSV file.
-- 'added_to_netflix' is initially VARCHAR to facilitate easier import of mixed date formats.
-- 'rating' is DECIMAL(3,1) as it's a numerical rating in your data.
CREATE TABLE netflix_titles (
    title VARCHAR(255) NOT NULL,
    type VARCHAR(10) NOT NULL,
    release_year INT,
    added_to_netflix VARCHAR(50),   -- Temporarily VARCHAR for import flexibility
    country VARCHAR(255),
    genre VARCHAR(255),             -- Matches 'genre' column in my CSV
    duration VARCHAR(50),
    rating DECIMAL(3,1),            -- Matches 'rating' (numerical) in my CSV
    cast_count INT,                 -- Matches 'cast_count' in my CSV
    language VARCHAR(50)            -- Matches 'language' in my CSV
    -- Note: 'show_id', 'director', 'cast' (text), 'description' are NOT in your attached CSV.
    -- If your full dataset has these, you'd need to adjust this schema.
);
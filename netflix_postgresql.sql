-- Basic Information Retrieval

-- 1. List all movie titles.
		SELECT title FROM netflix;

-- 3. Display titles along with their release year.
		SELECT title, release_year FROM netflix;

--  Filtering by Date

-- 2. Show all TV Shows released in 2021.
		SELECT * FROM netflix
		WHERE type = 'TV Show' AND release_year = 2021;

-- 4. Show the name and type of content added in September 2021.
		SELECT title, type FROM netflix 
		WHERE date_added LIKE 'September%2021';

-- 6. List all shows added after September 22, 2021.
		SELECT title, type, date_added
		FROM netflix
		WHERE TO_DATE(date_added, 'Month DD, YYYY') > DATE '2021-09-22';

-- 8. Get all content added between September 20 and September 24, 2021.
	SELECT title, type
	FROM netflix
	WHERE TO_DATE(date_added, 'Month DD, YYYY') 
	BETWEEN DATE '2021-09-20' AND DATE '2021-09-24';

-- 23. Show the latest 10 added titles.
		SELECT title, date_added FROM netflix
		WHERE TO_DATE(date_added, 'Month DD, YYYY') IS NOT NULL 
		ORDER BY TO_DATE(date_added, 'Month DD, YYYY') DESC
		LIMIT 10;

--  Content Type & Count Statistics

-- 9. Count how many Movies and TV Shows are there.
		SELECT type, COUNT(type) AS total_types FROM netflix 
		GROUP BY type 
		ORDER BY 2 DESC;

-- 10. Count the number of titles by country.
		SELECT country, COUNT(*) AS title_count
		FROM netflix
		GROUP BY country
		ORDER BY title_count DESC;

-- 11. Find how many shows were released each year.
		SELECT release_year, COUNT(release_year) AS total_year
		FROM netflix 
		GROUP BY release_year
		ORDER BY release_year DESC;

-- 29. Percentage breakdown of Movies vs TV Shows.
		SELECT type,
        COUNT(*) AS count,
		ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_of_total
		FROM netflix
		GROUP BY type;

-- 30. Which month had the highest number of new additions to Netflix?
	SELECT TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month,
    COUNT(*) AS title_count
	FROM netflix
	WHERE date_added IS NOT NULL
	GROUP BY month
	ORDER BY title_count DESC;
	
--  Durations and Rankings

-- 12. Get average duration of movies and TV Shows.
	SELECT
    AVG(CASE WHEN type = 'Movie' THEN CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) END) AS avg_movie_duration,
    AVG(CASE WHEN type = 'TV Show' THEN CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) END) AS avg_tvshow_seasons
	FROM netflix
	WHERE duration IS NOT NULL;

-- 22. List top 5 longest movies.
	SELECT title, duration
	FROM netflix
	WHERE type = 'Movie' AND duration IS NOT NULL
	ORDER BY CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) DESC
	LIMIT 5;

-- 24. List all TV shows sorted by number of seasons descending.
	SELECT title, type, duration FROM netflix 
	WHERE type = 'TV Show'
	ORDER BY duration DESC;

-- 28. Which is the longest movie from each country?
	WITH ranked_movies AS (
	  SELECT country, title,
	         CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) AS duration_min,
         ROW_NUMBER() OVER (PARTITION BY country ORDER BY CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) DESC) AS rank
 	FROM netflix
 	WHERE type = 'Movie' AND duration IS NOT NULL
	)
	SELECT country, title, duration_min
	FROM ranked_movies
	WHERE rank = 1;
	
--  Director and Cast Insights

-- 13. List how many titles each director has directed.
		SELECT director, COUNT(director) AS title_count 
		FROM netflix 
		WHERE director IS NOT NULL
		GROUP BY director
		ORDER BY title_count DESC;

-- 15. List all shows directed by ‘Mike Flanagan’.
		SELECT title, type FROM netflix 
		WHERE director = 'Mike Flanagan';

-- 26. List directors who directed more than one title.
		SELECT director, COUNT(*) AS director_count
		FROM netflix
		WHERE director IS NOT NULL
		GROUP BY director
		HAVING COUNT(*) > 1
		ORDER BY director_count DESC;

-- 32. Get directors who have directed more than average number of titles.
		SELECT director, COUNT(*) AS title_count
		FROM netflix
		WHERE director IS NOT NULL
		GROUP BY director
		HAVING COUNT(*) > (
		    SELECT AVG(title_count)
		    FROM (
		        SELECT COUNT(*) AS title_count
		        FROM netflix
		        WHERE director IS NOT NULL
		        GROUP BY director
		    ) AS director_counts
		);

-- 34. Find the most recent movie per director.
		WITH ranked_movies AS (
		  SELECT director, title, TO_DATE(date_added, 'Month DD, YYYY') AS added_date,
		         ROW_NUMBER() OVER (PARTITION BY director ORDER BY TO_DATE(date_added, 'Month DD, YYYY') DESC) AS rn
		  FROM netflix
		  WHERE type = 'Movie' AND director IS NOT NULL
		)
		SELECT director, title, added_date
		FROM ranked_movies
		WHERE rn = 1;
		
-- Country-Based Queries

-- 5. Get the cast of all titles from the United States.
		SELECT casts, title FROM netflix
		WHERE country ILIKE '%United States%';

-- 17. Find all shows where ‘India’ is the country.
		SELECT title, type FROM netflix 
		WHERE country = 'India' AND type = 'TV Show';

-- 27. Get the country with the most TV Shows.
		SELECT country, COUNT(type) AS highest_count FROM netflix
		WHERE type = 'TV Show' AND country IS NOT NULL
		GROUP BY country
		ORDER BY highest_count DESC;
		
--  Content Filtering by Keywords & Genre

-- 14. Find all content rated 'TV-MA'.
		SELECT * FROM netflix 
		WHERE rating = 'TV-MA';

-- 16. Find movies longer than 100 minutes.
		SELECT title, type FROM netflix
		WHERE duration > '100 min' AND type = 'Movie';

-- 18. Get shows listed under 'Documentaries'.
		SELECT title, type FROM netflix 
		WHERE listed_in = 'Documentaries';

-- 19. Find all titles with the word ‘Love’ in the title.
		SELECT title FROM netflix 
		WHERE title ILIKE '%love%';

-- 20. Get shows where cast includes ‘Paul’.
		SELECT title, type FROM netflix 
		WHERE casts ILIKE '%Paul%';

-- 21. Find shows where description contains 'family'.
		SELECT title, type FROM netflix 
		WHERE description ILIKE '%family%';
		
-- 🕓 Time-Based Insights

-- 7. Find the earliest added content.
		SELECT type, title, date_added FROM netflix
		ORDER BY TO_DATE(date_added, 'Month DD, YYYY') ASC;

-- 31. Titles released in one year but added later to Netflix.
		SELECT title, release_year, TO_DATE(date_added, 'Month DD, YYYY') AS added_date,
		       (EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year) AS delay_years
		FROM netflix
		WHERE date_added IS NOT NULL
		ORDER BY delay_years DESC
		LIMIT 10;

-- 33. Calculate the cumulative number of titles released each year.
		SELECT release_year, COUNT(*) AS yearly_titles,
		       SUM(COUNT(*)) OVER (ORDER BY release_year) AS cumulative_titles
		FROM netflix
		GROUP BY release_year
		ORDER BY release_year;
		
-- Ratings

-- 25. Get the most common rating for TV Shows.
		SELECT type, rating, COUNT(rating) AS rating_count 
		FROM netflix 
		WHERE type = 'TV Show'
		GROUP BY type, rating
		ORDER BY rating_count DESC;
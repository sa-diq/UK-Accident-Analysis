--CHECK FIRST FEW ROWS OF THE TABLES

SELECT TOP (5) *
FROM dbo.accident;

SELECT TOP (5) *
FROM dbo.vehicle;

SELECT TOP (5) *
FROM dbo.casualty;

--Q1. HOW MANY ACCIDENTS WERE RECORDED EACH YEAR? 

SELECT
	accident_year,
	COUNT(DISTINCT accident_index) AS 'Total Recorded Accidents'
FROM dbo.accident
GROUP BY accident_year
ORDER BY accident_year;


-- Q2. HOW MANY ACCIDENTS OCCURED IN URBAN VS. RURAL AREAS?

SELECT
	urban_or_rural_area AS 'Area',
	COUNT(urban_or_rural_area) AS 'Total Recorded Accidents'
FROM dbo.accident
GROUP BY urban_or_rural_area;


-- Q3. DAY OF THE WEEK WITH HIGHEST NUMBER OF ACCIDENTS

SELECT
	day_of_week,
	COUNT(day_of_week) AS 'Total Recorded Accidents'
FROM dbo.accident
GROUP BY day_of_week
ORDER BY 'Total Recorded Accidents';


-- Q4. PROPORTIONS OF ACCIDENTS DURING DIFFERENT WEATHER CONDITIONS?

SELECT
	weather_conditions,
	COUNT(weather_conditions) AS 'Total Recorded Accidents',
	ROUND(COUNT(weather_conditions) * 100.0 / SUM(COUNT(weather_conditions)) OVER(), 2) AS 'Proportion'
FROM dbo.accident
GROUP BY weather_conditions
ORDER BY Proportion DESC;


-- Q5. FIVE MOST COMMON TYPE OF VEHICLES INVOLVED IN ACCIDENTS


SELECT
	TOP (5)
	vehicle_type,
	COUNT(accident_index) AS 'Number of Accidents'
FROM dbo.vehicle 
GROUP BY vehicle_type
ORDER BY 'Number of Accidents' DESC;


--Q6. AVERAGE AGE OF CASUALTIES FOR EACH TYPE OF VEHICLE INVOLVED IN ACCIDENTS

ALTER TABLE dbo.casualty
ALTER COLUMN age_of_casualty int;

SELECT
	v.vehicle_type,
	AVG(c.age_of_casualty) AS 'Average_Age'
FROM dbo.casualty c
JOIN dbo.vehicle v
ON c.accident_index = v.accident_index
GROUP BY vehicle_type
ORDER BY 'Average_Age';


ALTER TABLE dbo.accident
ALTER COLUMN number_of_casualties int;

SELECT accident_year, AVG(CAST(number_of_casualties AS DECIMAL(10,2))) as 'cas'
FROM dbo.accident
group by accident_year
;

--Q7. PROPORTION OF ACCIDENTS IN URBAN AREAS BY WEATHER CONDITION


SELECT
  weather_conditions,
  urban_or_rural_area,
  COUNT(*) AS total_accidents,
  CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY weather_conditions) AS DECIMAL(5,2)) AS proportion
FROM dbo.accident
WHERE urban_or_rural_area IN (1,2) -- (1=Urban, 2=Rural)
GROUP BY weather_conditions, urban_or_rural_area
ORDER BY weather_conditions, proportion DESC;

-- Q8. ACCIDENTS WITH UNUSUAL NUMBERS OF CASUALTIES COMPARED TO THE AVERAGE


WITH AvgCasualties AS (
  SELECT AVG(CAST(number_of_casualties AS DECIMAL(10, 2))) AS avg_casualties
  FROM dbo.accident
)
SELECT
  accident_index,
  number_of_casualties,
  CASE
    WHEN number_of_casualties > 2 * avg_casualties THEN 'High Casualties' -- Greater than double of the AVG casualties
    WHEN number_of_casualties < 0.5 * avg_casualties THEN 'Low Casualties' -- Less than half of the AVG casualties
    ELSE 'Normal Casualties'
  END AS casualties_category
FROM dbo.accident, AvgCasualties;

-- Q9. MOVING AVERAGE OF ACCIDENTS OVER A 7-DAY PERIOD 

SELECT
  date,
  COUNT(*) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_accidents
FROM dbo.accident
ORDER BY date;


-- Q10. JUNCTION TYPES WITH THE HIGHEST PROPORTION OF FATAL ACCIDENTS

WITH FatalAccidentProportion AS (
  SELECT
    junction_detail,
    COUNT(*) AS total_accidents,
    SUM(CASE WHEN accident_severity = 1 THEN 1 ELSE 0 END) AS fatal_accidents,
    CAST(SUM(CASE WHEN accident_severity = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS proportion_fatal
  FROM dbo.accident
  GROUP BY junction_detail
)
SELECT
  junction_detail,
  total_accidents,
  fatal_accidents,
  proportion_fatal
FROM FatalAccidentProportion
ORDER BY proportion_fatal DESC;


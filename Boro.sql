-- GENERATE  A VIEW FOR MIDDLESBROUGH

CREATE VIEW Middlesbrough AS  
SELECT
	a.date, a.time,
	a.accident_year, v.vehicle_type,
	v.sex_of_driver, v.age_of_driver,
	v.age_of_vehicle, v.engine_capacity_cc,
	a.number_of_casualties, a.day_of_week,
	a.local_authority_district, a.weather_conditions,
	a.road_type, c.casualty_severity,
	c.casualty_type, a.accident_severity,
	a.speed_limit, v.journey_purpose_of_driver,
	c.casualty_home_area_type
FROM dbo.vehicle v
JOIN dbo.accident a
	ON v.accident_index = a.accident_index
JOIN dbo.casualty c
	ON v.accident_index = c.accident_index
WHERE local_authority_district = 243; -- Middlesbrough


SELECT 
	CONCAT(d.forename, ' ', d.surname) as driver_name,
	s.number,
	l.milliseconds, l.lap, l.position,
	r.name as race_name, c.name as team_name
FROM lap_times l 
JOIN drivers d 
	ON l.driver_id = d.driver_id
JOIN results s ON 
	l.driver_id = s.driver_id AND
	l.race_id = s.race_id
JOIN constructors c ON
	s.constructor_id = c.constructor_id
JOIN races r ON
	l.race_id = r.race_id
WHERE r.year = 2020;




SELECT r.year, COUNT(*) as nrace
FROM
	(SELECT s.race_id
	FROM results s
	WHERE s.constructor_id = 6
	GROUP BY s.race_id
	) t1
JOIN races r 
ON t1.race_id = r.race_id
GROUP BY r.year
ORDER BY r.year;



COPY () TO 
'/Users/arthurgymer/git-repos/misc-analysis/analyses/f1/data/2020_laps.csv'
WITH CSV DELIMITER ',' 
HEADER;


COPY (SELECT CONCAT(left(d.forename, 1), '. ', d.surname), r.position, s.year, s.round 
FROM results r 
JOIN races s ON r.race_id = s.race_id 
JOIN drivers d ON d.driver_id = r.driver_id 
WHERE r.driver_id in 
(SELECT driver_id 
FROM results 
WHERE position=1 
GROUP BY driver_id 
HAVING COUNT(*) >= 20)) TO '/Users/arthurgymer/git-repos/misc-analysis/analyses/f1/data/20_plus_wins.csv'WITH CSV DELIMITER ',' 
HEADER;

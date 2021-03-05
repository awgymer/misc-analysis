CREATE TABLE IF NOT EXISTS status (
	status_id	INTEGER	PRIMARY KEY,
	status		TEXT	NOT NULL
);


CREATE TABLE IF NOT EXISTS seasons (
	year	INTEGER	PRIMARY KEY,
	url		TEXT	NOT NULL
);


CREATE TABLE IF NOT EXISTS circuits (
	circuit_id	INTEGER	PRIMARY KEY,
	circuit_ref	TEXT	NOT NULL,
	name		TEXT	NOT NULL,
	location	TEXT,
	country		TEXT,
	lat			REAL,
	lng			REAL,
	alt			INTEGER,
	url			TEXT	NOT NULL
);


CREATE TABLE IF NOT EXISTS drivers (
	driver_id	INTEGER	PRIMARY KEY,
	driver_ref	TEXT	NOT NULL,
	number		INTEGER,
	code		VARCHAR(3),
	forename	TEXT	NOT NULL,
	surname		TEXT	NOT NULL,
	dob			DATE,
	nationality	TEXT,
	url			TEXT	NOT NULL
);


CREATE TABLE IF NOT EXISTS constructors (
	constructor_id	INTEGER	PRIMARY KEY,
	constructor_ref	TEXT	NOT NULL,
	name			TEXT	NOT NULL,
	nationality		TEXT,
	url				TEXT	NOT NULL
);


CREATE TABLE IF NOT EXISTS races (
	race_id		INTEGER	PRIMARY KEY,
	year		INTEGER	REFERENCES seasons(year) NOT NULL,
	round		INTEGER	NOT NULL,
	circuit_id	INTEGER	REFERENCES circuits(circuit_id) NOT NULL,
	name		TEXT	NOT NULL,
	date		DATE	NOT NULL,
	time		TIME,
	url			TEXT
);


CREATE TABLE IF NOT EXISTS constructor_results (
	constructor_results_id	INTEGER PRIMARY KEY,
	race_id					INTEGER REFERENCES races(race_id) NOT NULL,
	constructor_id			INTEGER REFERENCES constructors(constructor_id) NOT NULL,
	points					REAL,
	status					TEXT
);


CREATE TABLE IF NOT EXISTS constructor_standings (
	constructor_standings_id	INTEGER	PRIMARY KEY,
	race_id						INTEGER	REFERENCES races(race_id) NOT NULL,
	constructor_id				INTEGER	REFERENCES constructors(constructor_id) NOT NULL,
	points						REAL	NOT NULL,
	position					INTEGER,
	position_text				TEXT,
	wins						INTEGER	NOT NULL
);


CREATE TABLE IF NOT EXISTS driver_standings (
	driver_standings_id	INTEGER	PRIMARY KEY,
	race_id				INTEGER	REFERENCES races(race_id) NOT NULL,
	driver_id			INTEGER	REFERENCES drivers(driver_id) NOT NULL,
	points				REAL	NOT NULL,
	position			INTEGER,
	position_text		TEXT,
	wins				INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS lap_times (
	race_id			INTEGER	REFERENCES races(race_id) NOT NULL,
	driver_id		INTEGER	REFERENCES drivers(driver_id) NOT NULL,
	lap				INTEGER NOT NULL,
	position		INTEGER,
	time			TEXT,
	milliseconds	INTEGER,
	PRIMARY KEY (race_id, driver_id, lap)
);

CREATE TABLE IF NOT EXISTS pit_stops (
	race_id			INTEGER	REFERENCES races(race_id) NOT NULL,
	driver_id		INTEGER	REFERENCES drivers(driver_id) NOT NULL,
	stop			INTEGER NOT NULL,
	lap				INTEGER NOT NULL,
	time			TIME,
	duration		TEXT,
	milliseconds	INTEGER,
	PRIMARY KEY (race_id, driver_id, stop)
);

CREATE TABLE IF NOT EXISTS qualifying (
	qualify_id		INTEGER	PRIMARY KEY,
	race_id			INTEGER	REFERENCES races(race_id) NOT NULL,
	driver_id		INTEGER	REFERENCES drivers(driver_id) NOT NULL,
	constructor_id	INTEGER	REFERENCES constructors(constructor_id) NOT NULL,
	number			INTEGER	NOT NULL,
	position		INTEGER,
	q1				TEXT,
	q2				TEXT,
	q3				TEXT
);

CREATE TABLE IF NOT EXISTS results (
	result_id			INTEGER PRIMARY KEY,
	race_id				INTEGER	REFERENCES races(race_id) NOT NULL,
	driver_id			INTEGER	REFERENCES drivers(driver_id) NOT NULL,
	constructor_id		INTEGER	REFERENCES constructors(constructor_id) NOT NULL,
	number				INTEGER,
	grid				INTEGER	NOT NULL,
	position			INTEGER,
	position_text		TEXT	NOT NULL,
	position_order		INTEGER	NOT NULL,
	points				REAL	NOT NULL,
	laps				INTEGER	NOT NULL,
	time				TEXT,
	milliseconds		INTEGER,
	fastest_lap			INTEGER,
	rank				INTEGER,
	fastest_lap_time	TEXT,
	fastest_lap_speed	TEXT,
	status_id			INTEGER	REFERENCES status(status_id)
);
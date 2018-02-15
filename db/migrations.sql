CREATE DATABASE hunttest;

\c hunttest

CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	username VARCHAR(32),
	password_digest VARCHAR(60),
	email VARCHAR(32),
	creation_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE hunts(
	id SERIAL PRIMARY KEY,
	title VARCHAR(255),
	description VARCHAR(255),
	user_id INT REFERENCES users(id),
	hints TEXT[],
	victory_code VARCHAR(10),
	lat NUMERIC NOT NULL,
	long NUMERIC NOT NULL,
	zoom INT NOT NULL,
	active BOOLEAN DEFAULT 'true',
	creation_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE participants(
	id SERIAL PRIMARY KEY,
	user_id INT REFERENCES users(id),
	hunt_id INT REFERENCES hunts(id),
	hints_found TEXT[],
	completed BOOLEAN DEFAULT 'false',
	start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
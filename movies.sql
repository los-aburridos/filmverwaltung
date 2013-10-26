PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE movies (
	_id INTEGER NOT NULL,
	_tmdb_id INTEGER,
	_year VARCHAR,
	_title VARCHAR,
	_watched BOOLEAN,
	PRIMARY KEY (_id),
	UNIQUE (_title),
	CHECK (_watched IN (0, 1))
);
INSERT INTO "movies" VALUES(1,278,'1994','Die Verurteilten',0);
INSERT INTO "movies" VALUES(2,238,'1972','Der Pate',0);
INSERT INTO "movies" VALUES(3,240,'1974','Der Pate II',0);
INSERT INTO "movies" VALUES(4,680,'1994','Pulp Fiction',0);
INSERT INTO "movies" VALUES(5,429,'1966','Zwei glorreiche Halunken',1);
INSERT INTO "movies" VALUES(6,155,'2008','The Dark Knight',0);
INSERT INTO "movies" VALUES(7,389,'1957','Die zwölf Geschworenen',0);
INSERT INTO "movies" VALUES(8,424,'1993','Schindlers Liste',1);
INSERT INTO "movies" VALUES(9,122,'2003','Der Herr der Ringe - Die Rückkehr des Königs',0);
INSERT INTO "movies" VALUES(10,550,'1999','Fight Club',0);
INSERT INTO "movies" VALUES(11,1891,'1980','Das Imperium schlägt zurück',0);
INSERT INTO "movies" VALUES(12,120,'2001','Der Herr der Ringe - Die Gefährten',1);
INSERT INTO "movies" VALUES(13,510,'1975','Einer flog über das Kuckucksnest',0);
INSERT INTO "movies" VALUES(14,NULL,'1990','GoodFellas - Drei Jahrzente in der Mafia',0);
INSERT INTO "movies" VALUES(15,27205,'2010','Inception',0);
INSERT INTO "movies" VALUES(16,346,'1954','Die sieben Samurai',0);
INSERT INTO "movies" VALUES(17,11,'1977','Star Wars - Episode IV: Eine neue Hoffnung',0);
INSERT INTO "movies" VALUES(18,13,'1994','Forrest Gump',1);
INSERT INTO "movies" VALUES(19,603,'1999','Matrix',0);
INSERT INTO "movies" VALUES(20,121,'2002','Der Herr der Ringe - Die zwei Türme',0);
INSERT INTO "movies" VALUES(21,598,'2002','City of God',1);
COMMIT;

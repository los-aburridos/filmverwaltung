PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE movies (
	id INTEGER NOT NULL,
	year VARCHAR,
	title VARCHAR,
	watched BOOLEAN,
	PRIMARY KEY (id),
	UNIQUE (title),
	CHECK (watched IN (0, 1))
);
INSERT INTO "movies" VALUES(1,'1994','Die Verurteilten',0);
INSERT INTO "movies" VALUES(2,'1972','Der Pate',0);
INSERT INTO "movies" VALUES(3,'1974','Der Pate II',0);
INSERT INTO "movies" VALUES(4,'1994','Pulp Fiction',0);
INSERT INTO "movies" VALUES(5,'1966','Zwei glorreiche Halunken',1);
INSERT INTO "movies" VALUES(6,'2008','The Dark Knight',0);
INSERT INTO "movies" VALUES(7,'1957','Die zwölf Geschworenen',0);
INSERT INTO "movies" VALUES(8,'1993','Schindlers Liste',1);
INSERT INTO "movies" VALUES(9,'2003','Der Herr der Ringe - Die Rückkehr des Königs',0);
INSERT INTO "movies" VALUES(10,'1999','Fight Club',0);
INSERT INTO "movies" VALUES(11,'1980','Das Imperium schlägt zurück',0);
INSERT INTO "movies" VALUES(12,'2001','Der Herr der Ringe - Die Gefährten',1);
INSERT INTO "movies" VALUES(13,'1975','Einer flog über das Kuckucksnest',0);
INSERT INTO "movies" VALUES(14,'1990','GoodFellas - Drei Jahrzente in der Mafia',0);
INSERT INTO "movies" VALUES(15,'2010','Inception',0);
INSERT INTO "movies" VALUES(16,'1954','Die sieben Samurai',0);
INSERT INTO "movies" VALUES(17,'1977','Star Wars - Episode IV: Eine neue Hoffnung',0);
INSERT INTO "movies" VALUES(18,'1994','Forrest Gump',1);
INSERT INTO "movies" VALUES(19,'1999','Matrix',0);
INSERT INTO "movies" VALUES(20,'2002','Der Herr der Ringe - Die zwei Türme',0);
INSERT INTO "movies" VALUES(21,'2002','City of God',1);
COMMIT;

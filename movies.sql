PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE movies (
	id INTEGER NOT NULL,
	title VARCHAR,
	already_watched BOOLEAN,
	PRIMARY KEY (id),
	UNIQUE (title),
	CHECK (already_watched IN (0, 1))
);
INSERT INTO "movies" VALUES(1,'Die Verurteilten',0);
INSERT INTO "movies" VALUES(2,'Der Pate',0);
INSERT INTO "movies" VALUES(3,'Der Pate II',0);
INSERT INTO "movies" VALUES(4,'Pulp Fiction',0);
INSERT INTO "movies" VALUES(5,'Zwei glorreiche Halunken',1);
INSERT INTO "movies" VALUES(6,'The Dark Knight',0);
INSERT INTO "movies" VALUES(7,'Die zwölf Geschworenen',0);
INSERT INTO "movies" VALUES(8,'Schindlers Liste',1);
INSERT INTO "movies" VALUES(9,'Der Herr der Ringe - Die Rückkehr des Königs',0);
INSERT INTO "movies" VALUES(10,'Fight Club',0);
INSERT INTO "movies" VALUES(11,'Das Imperium schlägt zurück',0);
INSERT INTO "movies" VALUES(12,'Der Herr der Ringe - Die Gefährten',1);
INSERT INTO "movies" VALUES(13,'Einer flog über das Kuckucksnest',0);
INSERT INTO "movies" VALUES(14,'GoodFellas - Drei Jahrzente in der Mafia',0);
INSERT INTO "movies" VALUES(15,'Inception',0);
INSERT INTO "movies" VALUES(16,'Die sieben Samurai',0);
INSERT INTO "movies" VALUES(17,'Star Wars - Episode IV: Eine neue Hoffnung',0);
INSERT INTO "movies" VALUES(18,'Forrest Gump',1);
INSERT INTO "movies" VALUES(19,'Matrix',0);
INSERT INTO "movies" VALUES(20,'Der Herr der Ringe - Die zwei Türme',0);
INSERT INTO "movies" VALUES(21,'City of God',1);
COMMIT;

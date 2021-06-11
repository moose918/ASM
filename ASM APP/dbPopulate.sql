tee dbPopulate.rtf;

USE d2326254;

SET @USER_START = 10000;
SET @TEAM_START = 90000;
SET @GAME_START = 1;

INSERT INTO `USER` (USER_PICTURE, USER_FNAME, USER_LNAME, USER_DOB, USER_TYPE)
VALUES 
("moose918.jpg", "Musa", "Gumpu", "2002-02-03", "player"),
("mikey-mikey.jpg", "Michael", "le Forestier", "2001-06-04", "match_official"),
("KTG.jpg", "Katlego", "Kungoane", "2001-09-03", "spectator");

INSERT INTO `LOGIN` (USER_ID, LOGIN_UNAME, LOGIN_PASS)
VALUES 
(10000, "moose918", "moose"),
(10001, "mikey-mikey", "forest"),
(10002, "KatTheGee", "KTG");

INSERT INTO `MATCH_OFFICIAL` (USER_ID, MOFF_REFEREE, MOFF_ORGANIZER) 
VALUES 
(10001, true, true);

INSERT INTO `PLAYER` (USER_ID, PLAYER_FOOT)
VALUES
(10000, "L");

INSERT INTO `TEAM` (TEAM_NAME, TEAM_LOGO, TEAM_FOUNDED, USER_ID) 
VALUES
("Barefoot", "team.jpg", "2000-01-05", 10001 ),
("Ashigaru", "team.jpg", "2005-01-07", 10001),
("Storror", "team.jpg", "2010-10-10", 10001);

-- GAME SITUATION

INSERT INTO `GAME` (USER_ID, GAME_DATE, GAME_TIME)
VALUES
(10001, "2020-06-05", "08:00"),
(10001, "2021-03-10", "10:00"),
(10001, "2021-05-09", "14:00"),
(10001, "1999-10-09", "05:00"),
(10001, "2019-08-04", "12:00"),
(10001, "2012-08-15", "19:00");


INSERT INTO `MATCH` (GAME_ID, TEAM_ID, TEAM_SCORE)
VALUES
(1, 90000, 3),
(1, 90001, 1),
(2, 90001, 2),
(2, 90000, 0),
(3, 90002, 5),
(3, 90000, 1),
(4, 90002, 7),
(4, 90001, 3),
(5, 90000, 0),
(5, 90001, 0),
(6, 90001, 1),
(6, 90000, 1);


INSERT INTO `PLAYER_ARCHIVE` (GAME_ID, TEAM_ID, USER_ID, PARC_POSITION, PARC_GOALS_SCORED, PARC_CAPTAIN, PARC_RATING)
VALUES
(1, 90000, 10000, "MID", 2, false, 4.3),
(2, 90000, 10000, "ATT", 0, true, 3.0),
(6, 90000, 10000, "DEF", 1, true, 4.9);

TABLE `USER`;
TABLE `MATCH_OFFICIAL`;
TABLE `PLAYER`;
TABLE `PLAYER_ARCHIVE`;
TABLE `TEAM`;
TABLE `MATCH`;

notee;
INSERT INTO `USER` VALUES
(10000, "user.jpg", "Musa", "Gumpu", "2002-02-03", "player"),
(NULL, "user.jpg", "Michael", "le Forestier", "2001-06-04", "match_official"),
(NULL, "user.jpg", "Katlego", "Kungoane", "2001-09-03", "spectator");

INSERT INTO `LOGIN` VALUES
(10000, "moose918", "moose"),
(10001, "mikey-mikey", "forest"),
(10002, "KatTheGee", "KTG");

INSERT INTO `MATCH_OFFICIAL` VALUES
(10001, true, true);

INSERT INTO `PLAYER` VALUES
(10000, "L", 0, 0, 0, 0, 0);

INSERT INTO `TEAM` VALUES
(90000, "Barefoot", "team.jpg", "2000-01-05", 0, 0, 0, 0, 0, 0, 0, 0, 10001),
(NULL, "Ashigaru", "team.jpg", "2005-01-07", 0, 0, 0, 0, 0, 0, 0, 0, 10001);

-- GAME SITUATION

INSERT INTO `GAME` VALUES
(1, 10001, "2020-06-05", "08:00"),
(NULL, 10001, "2021-09-10", "10:00");

INSERT INTO `MATCH` VALUES
(1, 90000, 3),
(1, 90001, 1),
(2, 90001, 2),
(2, 90000, 0);


INSERT INTO `PLAYER_ARCHIVE` VALUES
(1, 90000, 10000, "MID", 2, false, 4.3),
(2, 90000, 10000, "ATT", 0, true, 3.0);
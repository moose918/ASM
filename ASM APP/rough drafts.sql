/*
	-- Parameterized table display
	SET @a = "CLASS_NEW";
SET @tableShow = CONCAT("SELECT * FROM ", @a);
PREPARE stmt FROM @tableShow;
EXECUTE stmt; -- USING @a;
DEALLOCATE PREPARE stmt;
*/

source dbSource.sql;
source dbFunctions.sql;
source dbTriggers.sql;
source dbPopulate.sql;

CALL UPDATE_PLAYER_STATS(10000);
CALL UPDATE_TEAM_STATS(90000);  

DELIMITER //
CREATE PROCEDURE UPDATE_TEAM_STATS(IN ID INTEGER UNSIGNED)
BEGIN
DECLARE playCount, wins, losses, draws, goalsFor, goalsAgainst INTEGER UNSIGNED DEFAULT 0;	
DECLARE goalDifference INTEGER DEFAULT 0;
DECLARE winRate DECIMAL(2,1) DEFAULT 0;

SET @teamID = teamID;

CALL CREATE_GAME_VIEWS();

CALL PREPARED_QUERY("COUNT(*)", "`TEAM_WINNER_LOSER`", "WINNER = @teamID");
SET wins = @outputResult;
CALL PREPARED_QUERY("COUNT(*)", "`TEAM_WINNER_LOSER`", "LOSER = @teamID");
SET losses = @outputResult;
CALL PREPARED_QUERY("COUNT(*)", "`TEAM_DRAWN_GAMES`", "TEAM_ID = @teamID");
SET draws = @outputResult;
SET playCount = wins + losses + draws;
SET winRate = wins/playCount * 100;


CALL PREPARED_QUERY("SUM(WINNER_SCORE) ", "`TEAM_WINNER_LOSER`", "WINNER = @teamID");
goalsFor = @outputResult;
CALL PREPARED_QUERY("SUM(LOSER_SCORE)", "`TEAM_WINNER_LOSER`", "LOSER = teamID");
goalsFor = goalsFor + @outputResult;
END //
DELIMITER ;


SET @query = CONCAT("CREATE VIEW `PLAYER_VIEW` AS ",
"SELECT GAME_ID, TEAM_ID, PARC_GOALS_SCORED AS GOALS_SCORED, PARC_CAPTAIN AS WAS_CAPTAIN, PARC_RATING AS PLAYER_RATING ",
"FROM `PLAYER_ARCHIVE` ",
"WHERE USER_ID = 10000");



SELECT DISTINCT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE > L.TEAM_SCORE);

source dbSource.sql;
source dbPopulate.sql;
TABLE `MATCH`;

SELECT MIN

SELECT DISTINCT MATCH_ID, T1, T1_SCORE, T2, T2_SCORE FROM

(SELECT DISTINCT T1.GAME_ID AS MATCH_ID, T1.TEAM_ID AS T1, T1.TEAM_SCORE AS T1_SCORE, T2.TEAM_ID AS T2, T2.TEAM_SCORE AS T2_SCORE 
FROM `MATCH` AS T1 INNER JOIN `MATCH` AS T2 
ON (T1.GAME_ID = T2.GAME_ID && T1.TEAM_ID != T2.TEAM_ID && T1.TEAM_SCORE = T2.TEAM_SCORE)) AS M;






DROP VIEW IF EXISTS `TEAM_WINNER_LOSER`;
DROP VIEW IF EXISTS `TEAM_DRAWN_GAMES`;

CREATE VIEW `TEAM_WINNER_LOSER`
AS
SELECT DISTINCT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE > L.TEAM_SCORE);

CREATE VIEW `TEAM_DRAWN_GAMES`
AS
SELECT T1.GAME_ID AS GAME_ID, T1.TEAM_ID AS TEAM_ID, T1.TEAM_SCORE AS TEAM_SCORE 
FROM `MATCH` AS T1 INNER JOIN `MATCH` AS T2 
ON (T1.GAME_ID = T2.GAME_ID && T1.TEAM_ID != T2.TEAM_ID && T1.TEAM_SCORE = T2.TEAM_SCORE);

DROP VIEW IF EXISTS `PLAYER_VIEW`;
DROP VIEW IF EXISTS `PLAYER_WINNER_LOSER`;
DROP VIEW IF EXISTS `PLAYER_DRAWN_GAMES`;

CREATE VIEW `PLAYER_VIEW`
AS
SELECT GAME_ID, TEAM_ID, PARC_GOALS_SCORED, PARC_CAPTAIN, PARC_RATING
FROM `PLAYER_ARCHIVE`
WHERE USER_ID = 10000;


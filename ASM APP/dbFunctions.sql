-- Start of procedure/function declaration
DELIMITER //


-- Used for after game completion, players involved should have their details be uppdated
CREATE PROCEDURE UPDATE_PLAYER_RECORD(IN playerID)
BEGIN
	DECLARE ratingCount INTEGER UNSIGNED DEFAULT 0;
	DECLARE totalRating DOUBLE DEFAULT 0;
	
/*
	-- Organize winners and losers in their respective columns with their respective scores
	( SELECT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
	FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
	ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE > L.TEAM_SCORE))
	
	-- Drawn Matches
	( SELECT DISTINCT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
	FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
	ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE = L.TEAM_SCORE))
	
	-- List of games and the teams the player played for, which a player has participated in
	(SELECT GAME_ID, TEAM_ID AS pGameIDs FROM `PLAYER_ARCHIVE` AS PARC WHERE PARC.USER_ID = userID)
	
	-- Parameterized table display
	SET @a = "CLASS_NEW";
SET @tableShow = CONCAT("SELECT * FROM ", @a);
PREPARE stmt FROM @tableShow;
EXECUTE stmt; -- USING @a;
DEALLOCATE PREPARE stmt;
*/

	-- Get game wins involving the player, swap 'PARC.USER_ID = playerID'
	SET wins :=
		SELECT COUNT(*)
		FROM 
		( SELECT DISTINCT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
		FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
		ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE > L.TEAM_SCORE)) AS R
		INNER JOIN
		( SELECT GAME_ID, TEAM_ID 
		FROM `PLAYER_ARCHIVE` AS PARC 
		WHERE PARC.USER_ID = 10000 ) AS P
		ON (R.GAME_ID = P.GAME_ID && R.WINNER = P.TEAM_ID);
		
	
	SET losses :=
		SELECT COUNT(*)
		FROM 
		( SELECT DISTINCT W.GAME_ID AS GAME_ID, W.TEAM_ID AS WINNER, W.TEAM_SCORE AS WINNER_SCORE, L.TEAM_ID AS LOSER, L.TEAM_SCORE AS LOSER_SCORE 
		FROM `MATCH` AS W INNER JOIN `MATCH` AS L 
		ON (W.GAME_ID = L.GAME_ID && W.TEAM_ID != L.TEAM_ID && W.TEAM_SCORE > L.TEAM_SCORE)) AS R
		INNER JOIN
		( SELECT GAME_ID, TEAM_ID 
		FROM `PLAYER_ARCHIVE` AS PARC 
		WHERE PARC.USER_ID = 10000 ) AS P
		ON (R.GAME_ID = P.GAME_ID && R.LOSER = P.TEAM_ID);
	
	
	SET wins = SELECT COUNT(DISTINCT GAME_ID) FROM 
	
	
	UPDATE `PLAYER
END//

CREATE FUNCTION GET_PLAYER_WINS(IN playerID)
RETURNS INTEGER UNSIGNED;
BEGIN
DECLARE

RETURN
END//

-- End of procedure/function declaration
DELIMITER ;
tee dbFunctions.rtf;

DROP PROCEDURE IF EXISTS UPDATE_USER_AGE;
DROP PROCEDURE IF EXISTS CREATE_GAME_VIEWS;
DROP PROCEDURE IF EXISTS CREATE_PLAYER_VIEWS;
DROP PROCEDURE IF EXISTS UPDATE_TEAM_STATS;
DROP PROCEDURE IF EXISTS UPDATE_PLAYER_STATS;


-- Start of procedure/function declaration
DELIMITER //

-- Update the users age
-- Done when starting up database after being inactive for a long time (days...)

CREATE PROCEDURE UPDATE_USER_AGE()
BEGIN
	UPDATE `USER`
	SET USER_AGE = 0;
END//

-- (Re)Create views which assist in updating player and team stats 
-- when the `MATCH` or `PLAYER_ARCHIVE` table is modified
-- These views are really helpful...

CREATE PROCEDURE CREATE_GAME_VIEWS()
BEGIN
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
END//


-- List of games and the teams the player played for, which a player has participated in
CREATE PROCEDURE CREATE_PLAYER_VIEWS(IN playerID INTEGER UNSIGNED)
BEGIN
	CALL CREATE_GAME_VIEWS();
	
	DROP VIEW IF EXISTS `PLAYER_VIEW`;
	DROP VIEW IF EXISTS `PLAYER_WINNER_LOSER`;
	DROP VIEW IF EXISTS `PLAYER_DRAWN_GAMES`;
	
	SET @query = CONCAT("CREATE VIEW `PLAYER_VIEW` AS ",
						"SELECT GAME_ID, TEAM_ID, PARC_GOALS_SCORED AS GOALS_SCORED, PARC_CAPTAIN AS WAS_CAPTAIN, PARC_RATING AS PLAYER_RATING ",
						"FROM `PLAYER_ARCHIVE` ",
						"WHERE USER_ID = ", playerID);
	
	PREPARE createView FROM @query;
	EXECUTE createView;
	DEALLOCATE PREPARE createView;
	
	
	CREATE VIEW `PLAYER_WINNER_LOSER`
	AS
	SELECT WL.GAME_ID, IF(WINNER = PV.TEAM_ID, "W", "L") AS WIN_LOSS,
			IF(WINNER = PV.TEAM_ID, WINNER_SCORE, LOSER_SCORE ) AS GOALS_FOR, 
			IF(WINNER != PV.TEAM_ID, WINNER_SCORE, LOSER_SCORE) AS GOALS_AGAINST,
			GOALS_SCORED,
			PLAYER_RATING
	FROM `TEAM_WINNER_LOSER` AS WL INNER JOIN PLAYER_VIEW AS PV
	ON WL.GAME_ID = PV.GAME_ID && (WL.WINNER = PV.TEAM_ID || WL.LOSER = PV.TEAM_ID);

	CREATE  VIEW `PLAYER_DRAWN_GAMES`
	AS
	SELECT DG.GAME_ID, DG.TEAM_ID, TEAM_SCORE
	FROM `TEAM_DRAWN_GAMES` AS DG INNER JOIN `PLAYER_VIEW` AS PV
	ON DG.GAME_ID = PV.GAME_ID && DG.TEAM_ID = PV.TEAM_ID;
	
END//


-- Process parameterized query
-- Mandatory to execute prepared statements for parameterized queries
-- A procedure will store the results in a user defined variable
CREATE PROCEDURE PREPARED_QUERY(IN selectColumns TEXT, IN tableName TEXT, IN whereClause TEXT)
BEGIN
	SET @query = CONCAT("SELECT ", selectColumns, " INTO @outputResult FROM ", tableName, " WHERE ", whereClause);
	PREPARE selectQuery FROM @query;
	EXECUTE selectQuery;
	DEALLOCATE PREPARE selectQuery;
END//


-- Update the team stats
-- Done when the match table is affected
-- The main reason for using this procedure on triggers on the `MATCH` table instead of
-- manually passing values relating to a match the team was involved in
-- is because the latter becomes more complex as one would need to determine
-- whether we are deleting or inserting/updating, whether it was a 
-- positive/negative influence that needs to be reversed (such as a negative goal difference being reversed)...

CREATE PROCEDURE UPDATE_TEAM_STATS(IN teamID INTEGER UNSIGNED)
BEGIN
	DECLARE playCount, wins, losses, draws, goalsFor, goalsAgainst INTEGER UNSIGNED DEFAULT 0;	
	DECLARE goalDifference INTEGER DEFAULT 0;
	DECLARE winRate DECIMAL(4,2) DEFAULT 0;
	
	set @teamID = teamID;
	
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
	SET goalsFor = @outputResult;
	CALL PREPARED_QUERY("SUM(LOSER_SCORE)", "`TEAM_WINNER_LOSER`", "LOSER = @teamID");
	SET goalsFor = goalsFor + @outputResult;
	
	CALL PREPARED_QUERY("SUM(LOSER_SCORE) ", "`TEAM_WINNER_LOSER`", "WINNER = @teamID");
	SET goalsAgainst = @outputResult;
	CALL PREPARED_QUERY("SUM(WINNER_SCORE) ", "`TEAM_WINNER_LOSER`", "LOSER = @teamID");
	SET goalsAgainst = goalsAgainst + @outputResult;
	
	-- Since games here have been drawn, the score is the same for both teams
	CALL PREPARED_QUERY("SUM(TEAM_SCORE)", "`TEAM_DRAWN_GAMES`", "TEAM_ID = @teamID");
	SET goalsFor = goalsFor + @outputResult;
	SET goalsAgainst = goalsAgainst + @outputResult;
					
	CALL PREPARED_QUERY("SUM(WINNER_SCORE - LOSER_SCORE) ", "`TEAM_WINNER_LOSER`", "WINNER = @teamID");
	SET goalDifference = @outputResult;
	CALL PREPARED_QUERY("SUM(LOSER_SCORE - WINNER_SCORE) ", "`TEAM_WINNER_LOSER`", "LOSER = @teamID");
	SET goalDifference = goalDifference + @outputResult;
	
	UPDATE `TEAM` 
	SET 
	TEAM_PCOUNT = playCount,
	TEAM_WINS = wins,
	TEAM_LOSSES = losses,
	TEAM_DRAWS = draws,
	TEAM_G_FOR = goalsFor,
	TEAM_G_AGAINST = goalsAgainst,
	TEAM_G_DIFF = goalDifference,
	TEAM_WIN_RATE = winRate
	WHERE TEAM_ID = teamID;
	
END//

-- Update the player stats
-- Similar to updating team stats, but is much more specific

CREATE PROCEDURE UPDATE_PLAYER_STATS(IN playerID INTEGER UNSIGNED)
BEGIN
	DECLARE playCount, wins, losses, draws, goalsScored, goalsFor, goalsAgainst, captainCount INTEGER UNSIGNED DEFAULT 0;
	DECLARE averageRating DOUBLE DEFAULT 0;
	
	SET @playerID = playerID;
	
	CALL CREATE_PLAYER_VIEWS(playerID);
	
	CALL PREPARED_QUERY("SUM(GOALS_SCORED)", "`PLAYER_VIEW`", "true");
	SET goalsScored = @outputResult;
	CALL PREPARED_QUERY("COUNT(*)", "`PLAYER_VIEW`", "WAS_CAPTAIN = true");
	SET captainCount = @outputResult;
	
	CALL PREPARED_QUERY("SUM(PLAYER_RATING)", "`PLAYER_VIEW`", "true");
	SET averageRating = @outputResult;
	CALL PREPARED_QUERY("COUNT(*)", "`PLAYER_VIEW`", "true");
	SET playCount = @outputResult;
	SET averageRating = averageRating / playCount;
	
	CALL PREPARED_QUERY("SUM(GOALS_FOR)", "`PLAYER_WINNER_LOSER`", "true");
	SET goalsFor = @outputResult;
	CALL PREPARED_QUERY("SUM(GOALS_AGAINST)", "`PLAYER_WINNER_LOSER`", "true");
	SET goalsAgainst = @outputResult;
	CALL PREPARED_QUERY("SUM(GOALS_AGAINST)", "`PLAYER_WINNER_LOSER`", "true");	

	-- Since games here have been drawn, the score is the same for both teams
	CALL PREPARED_QUERY("SUM(TEAM_SCORE)", "`PLAYER_DRAWN_GAMES`", "true");
	SET goalsFor = goalsFor + @outputResult;
	SET goalsAgainst = goalsAgainst + @outputResult;

	
	CALL PREPARED_QUERY("COUNT(*)", "`PLAYER_WINNER_LOSER`", "WIN_LOSS = 'W'");
	SET wins = @outputResult;
	CALL PREPARED_QUERY("COUNT(*)", "`PLAYER_WINNER_LOSER`", "WIN_LOSS = 'W'");	
	SET losses = @outputResult;
	CALL PREPARED_QUERY("COUNT(*)", "`PLAYER_DRAWN_GAMES`", "true");
	SET draws = @outputResult;
	
	UPDATE `PLAYER`
	SET
	PLAYER_PCOUNT = playCount,
	PLAYER_CAPTAIN_COUNT = captainCount,
	PLAYER_TWINS = wins,
	PLAYER_TLOSSES = losses,
	PLAYER_TDRAWS = draws,
	PLAYER_T_G_SCORED = goalsScored,
	PLAYER_T_G_FOR = goalsFor,
	PLAYER_T_G_AGAINST = goalsAgainst,
	PLAYER_AVG_RATING = averageRating
	WHERE USER_ID = playerID;
END//

DELIMITER ;

notee;
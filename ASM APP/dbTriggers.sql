tee dbTriggers.rtf;

DELIMITER //

--
-- `USER` triggers
--

--  After inserting and updating a `USER`, their age needs to be kept up to date
-- Unfortuantely there is no GOTO statement to point to the repeated procedures for these triggers
-- At the start of the app, a check for updating ages will also be done since it can be a while since the last time the DB was active


CREATE TRIGGER on_insert_user
BEFORE INSERT
ON `USER` 
FOR EACH ROW
BEGIN
	DECLARE age INTEGER;
	
	SET age = TIMESTAMPDIFF(YEAR, NEW.USER_DOB, CURRENT_DATE());
	
	IF (age != NEW.USER_AGE) THEN
		SET NEW.USER_AGE = age;
	END IF;
END//


CREATE TRIGGER on_update_user
BEFORE UPDATE
ON `USER` 
FOR EACH ROW
BEGIN
	DECLARE age INTEGER;
	
	SET age = TIMESTAMPDIFF(YEAR, NEW.USER_DOB, CURRENT_DATE());
	
	IF (age != NEW.USER_AGE) THEN
		SET NEW.USER_AGE = age;
	END IF;
END//

DELIMITER ;

notee;

/*
--
-- `PLAYER_ARCHIVE` triggers
--

-- After inserting/deleting/updating a `PLAYER_ARCHIVE`, the PLAYER stats need to be updated
-- This will be done with the use of a procedure

CREATE TRIGGER after_insert_player_archive
AFTER INSERT
ON `PLAYER_ARCHIVE`
FOR EACH ROW
BEGIN
	CALL UPDATE_PLAYER_STATS(NEW.USER_ID);
END//

CREATE TRIGGER on_delete_player_archive
AFTER DELETE
ON `PLAYER_ARCHIVE`
FOR EACH ROW
BEGIN
	CALL UPDATE_PLAYER_STATS(OLD.USER_ID);
END//

CREATE TRIGGER after_update_player_archive
AFTER UPDATE
ON `PLAYER_ARCHIVE`
FOR EACH ROW
BEGIN
	CALL UPDATE_PLAYER_STATS(NEW.USER_ID);
END//

--
-- `MATCH` triggers
--

-- During inserting/deleting/updating a `MATCH`, the TEAM stats will need to be updated
-- This will also be done with the use of a procedure

CREATE TRIGGER after_insert_match
AFTER INSERT
ON `MATCH`
FOR EACH ROW
BEGIN 
	CALL UPDATE_TEAM_STATS(NEW.TEAM_ID);
END//

CREATE TRIGGER after_delete_match
AFTER DELETE
ON `MATCH`
FOR EACH ROW
BEGIN
	CALL UPDATE_TEAM_STATS(OLD.TEAM_ID);
END//

CREATE TRIGGER after_update_match
AFTER UPDATE
ON `MATCH`
FOR EACH ROW
BEGIN
	CALL UPDATE_TEAM_STATS(NEW.TEAM_ID);
END//
*/


USE test;
DELIMITER //

DROP PROCEDURE IF EXISTS AssertEqual//
CREATE PROCEDURE AssertEqual(expected VARCHAR(4000), actual VARCHAR(4000), Msg VARCHAR(4000))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '42000'
		SELECT CONCAT('FAIL: expected "', expected, '" but was "', actual, '" (', Msg, ')');
	IF NOT (expected LIKE BINARY actual) THEN
		CALL not_a_real_error;
	END IF;
END//
DROP PROCEDURE IF EXISTS AssertTrue//
CREATE PROCEDURE AssertTrue(actual BIT, Msg VARCHAR(4000))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '42000'
		SELECT CONCAT('FAIL: (', Msg, ')');
	IF (1 <> actual) THEN
		CALL not_a_real_error;
	END IF;
END//
DROP PROCEDURE IF EXISTS AssertFalse//
CREATE PROCEDURE AssertFalse(actual BIT, Msg VARCHAR(4000))
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '42000'
		SELECT CONCAT('FAIL: (', Msg, ')');
	IF (0 <> actual) THEN
		CALL not_a_real_error;
	END IF;
END//

DROP FUNCTION IF EXISTS IndexOf//
CREATE Function IndexOf(chr CHAR, str VARCHAR(4000))
	RETURNS INT
	BEGIN
	DECLARE pos INT;
	DECLARE strlen INT;
	DECLARE indexof INT;
	DECLARE isfound BIT;
    DECLARE thisChar CHAR;
	SET isfound = 0;
	SET pos = 0;
	SET strlen = LENGTH(str);
	SET indexof = -1;
	WHILE (isfound <> 1 AND pos <= strlen) DO
		SET thisChar = SUBSTRING(str, pos, 1);
		IF ASCII(thisChar) = ASCII(chr) THEN
		  SET isfound = 1;
		  SET indexof = pos;
		END IF;
		SET pos = pos + 1;
	END WHILE;
	RETURN indexof;
END//
DROP Function IF EXISTS CaesarMap//
CREATE Function CaesarMap(str VARCHAR(4000))
	RETURNS VARCHAR(4000)
	BEGIN
		DECLARE ALPH VARCHAR(72);
		DECLARE SUBST VARCHAR(72);
		DECLARE strlen INT;
		DECLARE pos INT;
		DECLARE retval VARCHAR(255);
		DECLARE thischar CHAR;
		DECLARE ALPHPOS INT;

		SET ALPH =  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
		SET SUBST = 'XYZABCDEFGHIJKLMNOPQRSTUVWxyzabcdefghijklmnopqrstuvw5678941230';

		SET strlen = LENGTH(str);
		SET pos = 1;
		SET retval = '';

		WHILE (pos <= strlen) DO
			SET thischar = MID(str, pos, 1);
			SET ALPHPOS = IndexOf(thischar, ALPH);
			SET retval = CONCAT(retval, SUBSTR(SUBST, ALPHPOS, 1));
			SET pos = pos + 1;
		END WHILE;

	  RETURN retval;
	END //

DELIMITER ;

CALL AssertEqual(2, INSTR('aqe', 'q'), 'INSTR: q is 2 in "aqe" in a 1-based world');

CALL AssertEqual(2, IndexOf('q', 'aqe'), 'IndexOf: q is 2 in "aqe" in a 1-based world');
CALL AssertEqual(5, IndexOf('Q', 'aqeqQe'), 'IndexOf: Q is 5 in "aqeqQe" in a 1-based world');

CALL AssertEqual('L', CaesarMap('A'), 'CaesarMap: A => L');
CALL AssertEqual('lmnop', CaesarMap('abcde'), 'CaesarMap: abcde => lmnop');
CALL AssertEqual('wxyza', CaesarMap('lmnop'), 'CaesarMap: lmnop => wxyza');
CALL AssertEqual('LMNOP', CaesarMap('ABCDE'), 'CaesarMap: ABCDE => LMNOP');
CALL AssertEqual('LMNOP', CaesarMap('ABCDE'), 'CaesarMap: ABCDE => LMNOP');
CALL AssertEqual('lmNop', CaesarMap('abCde'), 'CaesarMap: abCde => lmNop');
CALL AssertEqual('wxYza', CaesarMap('lmNop'), 'CaesarMap: lmNop => wxYza');
CALL AssertEqual('0', CaesarMap('0'), 'CaesarMap: 0 => 0');
CALL AssertEqual('?', CaesarMap('?'), 'CaesarMap: ? => ?');
CALL AssertEqual('0858353914', CaesarMap('0414919576'), 'CaesarMap: 0414919576 => 0858353914');


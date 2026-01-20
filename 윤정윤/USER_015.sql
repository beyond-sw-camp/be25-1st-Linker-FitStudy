-- 로그인된 아이디와 게시물 아이디를 통해 북마크 등록
DELIMITER $$
CREATE OR REPLACE PROCEDURE createBookmarkProc(
    IN userId INT,
    IN postId INT
)
BEGIN
    DECLARE CONTINUE HANDLER FOR 1062
        SELECT '이미 존재하는 북마크 입니다.' AS result;

    INSERT INTO bookmark(user_id, post_id)
    VALUES (userId, postId);
END$$
DELIMITER ;

CALL createBookmarkProc(1, 5);
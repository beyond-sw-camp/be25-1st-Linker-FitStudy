-- 로그인된 아이디와 게시물 아이디를 통해 북마크 해제
DELIMITER $$
CREATE OR REPLACE PROCEDURE deleteBookmarkProc(
    IN userId INT,
    IN postId INT
)
BEGIN
    DELETE FROM bookmark
    WHERE user_id = userId AND post_id = postId;
END$$
DELIMITER ;

CALL deleteBookmarkProc(1, 5);
-- 로그인된 아이디를 통해 북마크 목록 조회
DELIMITER $$
CREATE OR REPLACE PROCEDURE showBookmarkProc(
    IN userId INT
)
BEGIN
    SELECT bookmark.*,
           sp.title
    FROM bookmark
             LEFT OUTER JOIN study_post sp ON bookmark.post_id = sp.post_id
    WHERE user_id = userId;
END$$
DELIMITER ;

CALL showBookmarkProc(1);
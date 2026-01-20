DELIMITER $$
CREATE OR REPLACE PROCEDURE studyStatusProc(
    IN p_userId INT,
    IN p_studyStatus VARCHAR(20)
)
BEGIN
    SELECT
        sp.post_id,
        sp.title,
        sm.status AS '상태',
        sm.user_id
    FROM study_member sm
             JOIN study_post sp ON sp.post_id = sm.post_id
    WHERE sm.user_id = p_userId
      AND (
        p_studyStatus IS NULL
            OR sm.status = p_studyStatus
        );
END$$
DELIMITER ;

CALL studyStatusProc(10, 'PENDING');
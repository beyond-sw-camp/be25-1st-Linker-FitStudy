-- '거절됨' 스터디 내역 삭제
DELIMITER $$
CREATE OR REPLACE PROCEDURE deleteStudyRecordProc(
    IN userId INT,
    IN postId INT
)
BEGIN
    DELETE FROM study_member
    WHERE user_id = userId AND post_id = postId AND status = 'REJECTED';
END$$
DELIMITER ;

CALL deleteStudyRecordProc(1, 3);
-- ADMIN_003: 시스템 통계 대시보드
-- [프로시저] 시스템 통계 대시보드 (신규 공고 수, 신규 참여 수)
-- DROP PROCEDURE IF EXISTS proc_get_statistics;
DELIMITER //

CREATE PROCEDURE proc_get_statistics(
    IN p_start_date DATETIME,
    IN p_end_date DATETIME
)
BEGIN
    SELECT 
        (SELECT COUNT(*) 
         FROM study_post 
         WHERE created_at BETWEEN p_start_date AND p_end_date) AS '신규 스터디 수',
         
        (SELECT COUNT(*) 
         FROM study_member 
         WHERE joined_at BETWEEN p_start_date AND p_end_date
           AND status = 'ACCEPTED') AS '신규 참여 인원';
END //

DELIMITER ;
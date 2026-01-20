-- ===================== LEADER_008 =====================
-- 스터디 완료시 팀장권한으로 스터디 완료상태 변경
-- 스터디 완료시 협업완료 횟수 증가
-- 상태가 ACCEPTED 된 스터디 멤버만 completed_study 증가해야함
-- 완료로 변경시 accepted 된 회원만 completed_studies가 1 증가

DELIMITER $$
CREATE TRIGGER `trg_auto_increase_count`
AFTER UPDATE ON `study_post`
FOR EACH ROW
BEGIN
    -- 공고가 'COMPLETED'로 변경된 시점을 감지
    IF NEW.post_status = 'COMPLETED' AND OLD.post_status != 'COMPLETED' THEN  
        -- 상태가 ACCEPTED였던 스터디 멤버만 completed_studies가 1 증가
        UPDATE user
        SET completed_studies = completed_studies + 1
        WHERE user_id IN (
            SELECT user_id 
            FROM study_member 
            WHERE post_id = NEW.post_id 
              AND status = 'ACCEPTED'
        );
    END IF;
END$$

DELIMITER ;
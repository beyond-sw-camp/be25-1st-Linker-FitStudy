-- ===================== LEADER_004 =====================
-- 강퇴시 자동으로 리더 명의로 1점 부여
-- 상태가 KICKECD 일때만 작동
-- 이미 평가가 존재할 경우 IGNORE로 중복방지
DELIMITER $$
CREATE OR REPLACE TRIGGER `trg_auto_review_if_kicked`
AFTER UPDATE ON study_member
FOR EACH ROW
BEGIN
    DECLARE post_leader_id INT;
    IF NEW.status = 'KICKED' AND OLD.status != 'KICKED' THEN
        -- 1. 해당 스터디의 팀장 ID 찾기 (평가자 = 팀장)
        SELECT leader_id INTO post_leader_id
        FROM study_post
        WHERE post_id = NEW.post_id;

        -- 2. 팀장 이름으로 1점 자동 평가(에러 방지를 위해 IGNORE)
        INSERT IGNORE INTO peer_review 
        (post_id, reviewer_id, reviewee_id, contribution_score, communication_score, time_compliance_score, diligence_score)
        VALUES 
        (
            NEW.post_id,  -- 공고 ID
            post_leader_id,  -- 평가자 (팀장)
            NEW.user_id,  -- 피평가자 (강퇴된 멤버)
            1, 1, 1, 1    -- 점수 (전부 1점)
        );

        -- 강퇴된 유저의 penalty_count 1 증가
        UPDATE user
        SET penalty_count = IFNULL(penalty_count, 0) + 1
        WHERE user_id = NEW.user_id;

    END IF;
END$$
DELIMITER ;
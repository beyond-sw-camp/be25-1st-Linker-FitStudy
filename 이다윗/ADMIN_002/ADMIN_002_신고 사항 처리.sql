-- 1. ADMIN_001: 신고 사항 처리 및 공고 취소 연동

-- [프로시저] 신고 처리 (proc_process_report)

-- DROP PROCEDURE IF EXISTS proc_process_report;

DELIMITER //

CREATE PROCEDURE proc_process_report(
    IN p_report_id INT,
    IN p_admin_decision VARCHAR(20) -- 'ACCEPT' 또는 'REJECT'
)
BEGIN
    DECLARE v_target_user_id VARCHAR(50);
    DECLARE v_target_post_id INT;

    -- 1. 신고 대상 정보 가져오기
    SELECT target_id, target_post_id 
    INTO v_target_user_id, v_target_post_id
    FROM user_report
    WHERE report_id = p_report_id;

    -- 2. 신고 상태 업데이트 (처리중 -> 승인/거절)
    UPDATE user_report
    SET state = p_admin_decision
    WHERE report_id = p_report_id;

    -- 3. 신고가 '승인(ACCEPT)'된 경우 후속 처리
    IF p_admin_decision = 'ACCEPT' THEN
        
        -- 3-1. 피신고자(target_id)의 패널티 횟수 +1 증가
        UPDATE user
        SET penalty_count = penalty_count + 1
        WHERE user_id = v_target_user_id;

        -- 3-2. 허위 공고 신고일 경우(target_post_id가 존재함), 공고 상태를 'CANCELLED'로 변경
        IF v_target_post_id IS NOT NULL THEN
            UPDATE study_post
            SET post_status = 'CANCELED'
            WHERE post_id = v_target_post_id;
        END IF;
        
    END IF;

END //

DELIMITER ;

-- [트리거] 공고 취소 시 멤버 자동 탈퇴 (trg_auto_withdraw_members)

DELIMITER //

-- DROP TRIGGER trg_auto_withdraw_members;

CREATE TRIGGER trg_auto_withdraw_members
AFTER UPDATE ON study_post
FOR EACH ROW
BEGIN
    -- 공고 상태가 'CANCELED'로 변경되었을 때만 동작
    IF NEW.post_status = 'CANCELED' AND OLD.post_status != 'CANCELED' THEN
        
        -- 해당 공고에 참여 중인 멤버들의 상태를 'WITHDRAWN'(혹은 CANCELED)으로 변경
        -- JSON의 ENUM에 'CANCELED'가 있으므로 상황에 맞게 사용 (여기선 맥락상 CANCELED 사용)
        UPDATE study_member
        SET status = 'CANCELED'
        WHERE post_id = NEW.post_id
          AND status IN ('ACCEPTED', 'PENDING'); -- 이미 나간 사람 제외
          
    END IF;
END //

DELIMITER ;
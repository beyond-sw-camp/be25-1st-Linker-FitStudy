-- ===================== LEADER_005, LEADER_006 =====================
-- pending인 사람들 리더가 accept나 reject로 바꿈
DELIMITER $$
CREATE PROCEDURE `update_member_status`(
    IN p_post_id      INT,          -- 스터디 공고 ID
    IN p_requester_id INT,          -- 요청자 ID (리더인지 검증할 ID)
    IN p_target_id    INT,          -- 상태를 변경할 대상 회원 ID
    IN p_new_status   VARCHAR(20)   -- 변경할 상태 ('REJECTED', 'ACCEPTED' 등)
)
BEGIN
    -- 1. 업데이트 수행 (리더 권한 체크 포함)
    UPDATE study_member sm
    JOIN study_post sp ON sm.post_id = sp.post_id
    SET sm.status = p_new_status,
        sm.status_updated_at = NOW()
    WHERE sm.post_id = p_post_id
      AND sm.user_id = p_target_id   -- 변경 대상
      AND sp.leader_id = p_requester_id; -- 요청자가 리더여야만 실행됨

    -- 2. 결과 반환
    SELECT post_id, 
		 user_id, 
		 `role`, 
		 `status`,
		 status_updated_at
	 FROM study_member
	 WHERE post_id = p_post_id;
END$$
DELIMITER ;

-- 리더5가 유저2를 ACCEPTED함 성공
CALL sp_update_member_status(4, 5, 2, 'ACCEPTED');

-- 멤버3이 유저2를 ACCEPTED함 실패
CALL sp_update_member_status(4, 3, 2, 'ACCEPTED');

-- 리더 3이 멤버 6을 rejected함 성공
CALL sp_update_member_status(2, 3, 6, 'REJECTED');

-- 멤버 5가 유저 6을 rejeced함 실패 
CALL sp_update_member_status(2, 5, 6, 'REJECTED');

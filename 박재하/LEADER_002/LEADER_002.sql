-- ===================== LEADER_002 =====================
-- 팀장이 공고를 삭제하기 위해서는 참조하는 다른 자식 테이블을 먼저 삭제해야함
-- 채팅 읽음상태, 채팅메세지 삭제, 공고 태그삭제, 북마크 삭제, 동료평가 삭제, 신고내역 삭제, 스터디 멤버 삭제 순으로 해야함
-- 테이블을 ALTER CASCADE 하는 것 보단 트리거를 통해서 삭제
DROP TRIGGER IF EXISTS `trg_cleanup_on_post_cancel`;
DELIMITER $$

CREATE TRIGGER `trg_cleanup_on_post_cancel`
AFTER UPDATE ON `study_post`
FOR EACH ROW
BEGIN
    -- 공고 상태가 'CANCELED'로 변경된 경우에만 로직 수행
    IF NEW.post_status = 'CANCELED' AND OLD.post_status != 'CANCELED' THEN
    
        -- (1) 북마크: 삭제 처리
        DELETE FROM bookmark 
        WHERE post_id = NEW.post_id;

        -- (2) 스터디 멤버: 상태를 'CANCELED'로 변경
        -- 참여 중('ACCEPTED')이거나 대기 중('PENDING')인 멤버만 처리
        UPDATE study_member
        SET status = 'CANCELED',
            status_updated_at = NOW()
        WHERE post_id = NEW.post_id
          AND status IN ('PENDING', 'ACCEPTED');
          
    END IF;
END$$

DELIMITER ;

-- 트리거가 감지하고 북마크 삭제 + 멤버 상태 변경을 수행함
UPDATE study_post 
SET post_status = 'CANCELED' 
WHERE post_id = 1;
-- ===================== LEADER_003 =====================
-- 제목이나 내용을 수정. 반드시 leader_id만 수정가능해야함
DELIMITER $$
CREATE PROCEDURE `update_study_post`(
    IN p_post_id      INT,
    IN p_requester_id INT,
    IN p_title        VARCHAR(255),
    IN p_content      TEXT,
    IN p_way          VARCHAR(10)
)
BEGIN
    -- 1. 업데이트 수행 (권한 체크 포함)
    UPDATE study_post
    SET title      = p_title,
        content    = p_content,
        way        = p_way,
        updated_at = NOW()
    WHERE post_id = p_post_id 
      AND leader_id = p_requester_id;
    
    -- 2. 결과 조회
    SELECT sp.leader_id,
           sm.user_id,
           sp.title,
           sp.content,
           sp.way
    FROM study_member sm
    JOIN study_post sp ON sm.post_id = sp.post_id
    WHERE sp.post_id = p_post_id; 

END$$ 

DELIMITER ;

-- 멤버가 수정하는 경우 -> 수정 안됨
CALL update_study_post(2, 5, '제목 입력 ...', '상세 내용 입력 ...', 'ONLINE');

-- 리더가 수정하는 경우 -> 수정 됨
CALL update_study_post(2, 2, '제목 입력 ...', '상세 내용 입력 ...', 'ONLINE');

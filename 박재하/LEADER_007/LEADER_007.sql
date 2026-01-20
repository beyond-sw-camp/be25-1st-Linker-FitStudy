-- ===================== LEADER_007 =====================
-- 팀장이 공고가 시작 된 후 나가는 경우
-- 점수가 높은사람 순, 동률일 경우 먼저 들어온 순 으로 방장위임됨
-- 혹은 팀장이 팀원을 차기 팀장으로 지목 가능

DELIMITER $$
CREATE PROCEDURE `change_withdraw_leader`(
    IN p_post_id INT,        -- 공고 ID
    IN withdraw_leader_id INT, -- 탈퇴하는 팀장 ID
    IN next_leader_id INT  -- 후계자 ID (없으면 NULL)
)
BEGIN
    DECLARE is_leader INT;
    DECLARE final_leader_id INT;

    -- 1. 탈퇴하려는 사람이 팀장인지 확인
    SELECT COUNT(*) INTO is_leader
    FROM study_member
    WHERE post_id = p_post_id 
      AND user_id = withdraw_leader_id 
      AND role = 'LEADER';

    -- 2. 리더 본인 탈퇴 처리(멤버로 강등된 후 WITHDRAWN로 상태변경)
    UPDATE study_member 
    SET status = 'WITHDRAWN', status_updated_at = NOW(), role = 'MEMBER'
    WHERE post_id = p_post_id AND user_id = withdraw_leader_id;

    -- 3. 팀장이 나가는 경우에만 위임 로직 실행
    IF is_leader > 0 THEN
        -- 3-1. 사용자가 후계자를 지목한 경우 3-1-1, 아닌 경우 3-1-2
        IF next_leader_id IS NOT NULL THEN
            -- 3-1-1. 수동 위임: 입력받은 사람(next_leader_id)을 선택
            SET final_leader_id = next_leader_id;
            
        ELSE
            -- 3-1-2. 자동 위임: 신뢰도 1등 찾기
            SELECT u.user_id INTO final_leader_id
            FROM study_member sm
            JOIN user u ON sm.user_id = u.user_id
            WHERE sm.post_id = p_post_id 
              AND sm.status = 'ACCEPTED'
              AND sm.user_id != withdraw_leader_id
            ORDER BY u.reliability_score DESC, sm.joined_at ASC
            LIMIT 1;
        END IF;

        -- 4. 리더 변경 및 공고 업데이트
        IF final_leader_id IS NOT NULL THEN
            -- 멤버 직책 변경
            UPDATE study_member 
            SET role = 'LEADER'
            WHERE post_id = p_post_id AND user_id = final_leader_id;

            -- 공고 대표자 변경
            UPDATE study_post 
            SET leader_id = final_leader_id
            WHERE post_id = p_post_id;
        END IF;
    END IF;
END$$
DELIMITER ;

-- 2번 스터디, 3번 팀장 탈퇴, 후계자는 자동 선정(NULL)
CALL change_withdraw_leader(2, 3, NULL);

-- 2번 스터디, 3번 팀장 탈퇴, 후계자는 4번 유저 지정
CALL change_withdraw_leader(2, 3, 4);

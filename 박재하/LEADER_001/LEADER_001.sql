-- ===================== LEADER_001 =====================
-- 모집상태는 RECRUITING이 기본값
-- 팀장ID는 스터디 공고 만든 유저의 ID / 모집공고를 올리면 자동으로 리더 ID로 승격

DELIMITER $$
CREATE OR replace TRIGGER `trg_auto_leader_if_make_post`
AFTER INSERT ON `study_post`
FOR EACH ROW
BEGIN
    -- 공고가 생성되면, 작성자(leader_id)를 멤버 테이블에 자동 추가
    INSERT INTO study_member (post_id, user_id, role, status, joined_at)
    VALUES (NEW.post_id, NEW.leader_id, 'LEADER', 'ACCEPTED', NOW());
END$$
DELIMITER ;

INSERT INTO study_post 
(leader_id, title, content, max_participants, way, region_id, min_reliability, post_status, start_at, predict_finish_at) 
VALUES 
(
    5, -- 팀장ID
    '제목을 입력하세요... title', -- 제목
    '상세내용 입력하세요... ', -- 상세 내용
    4, -- 모집인원
    'ONLINE', -- 진행 방식 (ONLINE/OFFLINE/BOTH)
    NULL, -- 온라인이라 지역 없음
    4, -- 최소신뢰지수제한 (4점 이상)
    'RECRUITING', -- 모집 상태
    '2026-03-01 00:00:00', -- 스터디 시작일시
    '2026-06-01 00:00:00'  -- 예상 종료일시
);

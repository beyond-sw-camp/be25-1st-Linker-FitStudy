-- [ADMIN_001] 신고사항 조회
-- 신고사항 조회
SELECT 
    r.report_id,
    r.reason_type,        -- 신고 사유 (ABUSE, INSINCERITY 등)
    r.reason_detail,      -- 상세 내용
    r.state,              -- 처리 상태 (PROCESSING, ACCEPT, REJECT)
    r.created_at,         -- 신고 일시
    reporter.nickname AS reporter_name, -- 신고자 닉네임
    target.nickname AS target_name,     -- 피신고자(대상) 닉네임
    r.target_post_id      -- 신고 대상 공고 ID (있을 경우)
FROM user_report r
JOIN user reporter ON r.reporter_id = reporter.user_id
JOIN user target ON r.target_id = target.user_id
ORDER BY r.created_at DESC;

-- 상태별 필터링 조회 (예: 'PROCESSING' 처리중인 건만 조회)
SELECT 
    r.report_id,
    r.reason_type,
    r.state,
    r.created_at,
    reporter.nickname AS reporter_name,
    target.nickname AS target_name
FROM user_report r
JOIN user reporter ON r.reporter_id = reporter.user_id
JOIN user target ON r.target_id = target.user_id
WHERE r.state = 'PROCESSING' -- 'ACCEPT', 'REJECT'로 변경 가능
ORDER BY r.created_at DESC;

-- 신고 처리 상태 변경 (예: 신고 승인 처리)
-- :report_id 에는 처리할 report_id 값을 넣음
UPDATE user_report
SET 
    state = 'ACCEPT' -- 또는 'REJECT'
WHERE report_id = 1; -- 예시 ID


-- ACCEPT 변경 확인
SELECT 
    r.report_id,
    r.reason_type,
    r.state,
    r.created_at,
    reporter.nickname AS reporter_name,
    target.nickname AS target_name
FROM user_report r
JOIN user reporter ON r.reporter_id = reporter.user_id
JOIN user target ON r.target_id = target.user_id
WHERE r.state = 'accept' -- 'ACCEPT', 'REJECT'로 변경 가능
ORDER BY r.created_at DESC;
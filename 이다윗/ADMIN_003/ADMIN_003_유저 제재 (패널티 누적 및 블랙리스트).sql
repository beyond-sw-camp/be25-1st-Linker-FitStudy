-- 2. ADMIN_002: 유저 제재 (패널티 누적 및 블랙리스트)

-- [트리거] 신고 승인 시 패널티 증가 (trg_increase_penalty_on_report_accept)

DELIMITER //

CREATE TRIGGER trg_increase_penalty_on_report_accept
AFTER UPDATE ON user_report
FOR EACH ROW
BEGIN
    -- 신고 상태가 'ACCEPT'(승인)로 변경되었을 때만 실행
    IF NEW.state = 'ACCEPT' AND OLD.state != 'ACCEPT' THEN
        
        -- 피신고자(target_id)의 패널티 횟수 +1
        UPDATE user
        SET penalty_count = penalty_count + 1
        WHERE user_id = NEW.target_id;
        
    END IF;
END //

DELIMITER ;

-- [트리거] 3회 누적 시 강제 탈퇴 및 블랙리스트 (trg_enforce_blacklist)

DELIMITER //

CREATE TRIGGER trg_enforce_blacklist
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    -- 패널티가 3회 이상이 되는 순간 (기존엔 3 미만이었는데, 이번 업데이트로 3 이상이 됨)
    IF NEW.penalty_count >= 3 THEN
        
        -- 1. 회원 상태를 'WITHDRAWN'(탈퇴)으로 변경
        SET NEW.status = 'WITHDRAWN';
        
        -- 2. 블랙리스트 테이블에 이메일 등록 (중복 방지를 위해 INSERT IGNORE 사용 권장)
        -- reason에는 자동 등록 사유 기입
        INSERT IGNORE INTO black_list (email, reason, created_at)
        VALUES (OLD.email, '패널티 누적 3회 이상으로 인한 자동 차단', NOW());
        
    END IF;
END //

DELIMITER ;

-- [트리거] 블랙리스트에 등록된 이메일로 가입 시도 시 차단

DELIMITER //

CREATE TRIGGER trg_prevent_signup
BEFORE INSERT ON user
FOR EACH ROW
BEGIN
    -- 만약 가입하려는 이메일이 블랙리스트 테이블에 존재한다면 에러 발생
    IF EXISTS (SELECT 1 FROM black_list WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '차단된 계정(블랙리스트)입니다. 가입이 불가능합니다.';
    END IF;
END //
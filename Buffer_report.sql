-- Bảng 2:
SELECT
    rp.*,

    MONTH(rp.`Buổi cuối`) AS `Tháng`,
    YEAR(rp.`Buổi cuối`)  AS `Năm`,

    STR_TO_DATE(r.`Ngày`, '%d/%m/%Y') AS `Ngày hóa đơn gốc`,

    /* ===== ĐƠN GIA HẠN KHÁC (MAXIFS) ===== */
    (
        SELECT MAX(STR_TO_DATE(r2.`Ngày`, '%d/%m/%Y'))
        FROM receipt r2
        WHERE
            r2.HD <> r.HD
            AND r2.`Loại đơn hàng` = 'Repeat'
            AND r2.`Mã học viên` = rp.`Mã học sinh`
            AND r2.`Môn học` = rp.`Môn`
            AND r2.`Chương trình` = rp.`Chương trình`
            AND STR_TO_DATE(r2.`Ngày`, '%d/%m/%Y')
                < DATE_ADD(
                    STR_TO_DATE(r.`Ngày`, '%d/%m/%Y'),
                    INTERVAL 90 DAY
                )
    ) AS `Ngày đơn gia hạn khác`,
    CASE
    /* ===== 1. SUCCESSFUL ===== */
    WHEN EXISTS (
        SELECT 1
        FROM receipt r2
        WHERE
            r2.HD <> r.HD
            AND r2.`Loại đơn hàng` = 'Repeat'
            AND r2.`Mã học viên` = rp.`Mã học sinh`
            AND r2.`Môn học` = rp.`Môn`
            AND r2.`Chương trình` = rp.`Chương trình`
            AND STR_TO_DATE(r2.`Ngày`, '%d/%m/%Y')
                < DATE_ADD(STR_TO_DATE(r.`Ngày`, '%d/%m/%Y'), INTERVAL 90 DAY)
            AND STR_TO_DATE(r2.`Ngày`, '%d/%m/%Y')
                > `Ngày đơn gia hạn khác`
    )
    THEN 'successful'

    /* ===== 2. WAITING ===== */
    WHEN DATE_ADD(
            STR_TO_DATE(r.`Ngày`, '%d/%m/%Y'),
            INTERVAL 90 DAY
         ) > CURDATE()
    THEN 'waiting'

    /* ===== 3. OTHER RECEIPT ===== */
    WHEN EXISTS (
        SELECT 1
        FROM receipt_progress rp2
        WHERE
            rp2.`Mã học sinh` = rp.`Mã học sinh`
            AND rp2.`Chương trình` = rp.`Chương trình`
            AND rp2.`Size` = rp.`Size`
            AND rp2.`Buổi cuối`
                > STR_TO_DATE(r.`Ngày`, '%d/%m/%Y')
    )
    THEN 'other receipt'

    /* ===== 4. CÒN HĐ KHÁC ===== */
    WHEN EXISTS (
        SELECT 1
        FROM receipt_progress rp3
        WHERE
            rp3.`Mã học sinh` = rp.`Mã học sinh`
            AND rp3.`Môn` = rp.`Môn`
            AND rp3.`Số buổi còn lại` < 100
            AND STR_TO_DATE(rp3.`Buổi đầu`, '%Y-%m-%d')
                <= STR_TO_DATE(r.`Ngày`, '%d/%m/%Y')
    )
    THEN 'Còn HĐ khác'

    /* ===== 5. STOPPED ===== */
    ELSE 'stopped'
END AS `Retention`


FROM receipt_progress rp
JOIN receipt r
    ON rp.HD = r.HD
   AND rp.`Mã học sinh` = r.`Mã học viên`
   AND rp.`Môn` = r.`Môn học`

WHERE
    rp.`Chưa xếp lịch` < 1
    AND rp.Preserved < 1
    AND rp.`Loại đơn hàng` NOT IN ('Supplementary', 'Free lesson')
    AND rp.`Buổi cuối` IS NOT NULL
    AND MONTH(rp.`Buổi cuối`) = 12
    AND YEAR(rp.`Buổi cuối`) = 2025;




-- Bảng 1:
WITH buffer_report AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        s.Ca,
        s.`Trạng thái`,
        s.`Mã CVHT`,
        s.PTCM,
--         s.`Chương trình`,
        s.`Môn`,
        s.`Size`,
        WEEKDAY(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) + 2 AS `Thứ`,
        COUNT(
            CASE 
                WHEN s.`Trạng thái` = 'Completed' THEN 1 
            END
        ) OVER (
            PARTITION BY
                s.`Mã CVHT`,
                s.`Ngày học`,
                s.Ca,
                s.`Môn`
        ) AS `SỐ lượt hoàn thành`,
        COUNT(*) OVER (
            PARTITION BY
                s.`Mã CVHT`,
                s.`Ngày học`,
                s.Ca
        ) AS `TỔNG số lượt`
    FROM schedule s
    WHERE STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
) 
SELECT 
DISTINCT `Mã CVHT`, `Ngày học`, Ca, `Môn`, SIZE, `SỐ lượt hoàn thành`
, `TỔNG số lượt`
FROM buffer_report;
    

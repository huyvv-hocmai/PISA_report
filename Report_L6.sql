---------- Version chung
SELECT
    ri.`Chương trình`,
    ri.`Tháng ghi nhận hóa đơn` AS `Tháng`,
    ri.`Năm ghi nhận hóa đơn`   AS `Năm`,

    /* ===== Số học viên mới (unique) ===== */
    COUNT(DISTINCT
        CASE
            WHEN ri.`Loại đơn hàng` = 'New'
            THEN ri.`Mã học viên`
        END
    ) AS `Số học viên mới`,

    /* ===== Số hóa đơn New ===== */
    COUNT(
        DISTINCT CASE
            WHEN ri.`Loại đơn hàng` = 'New'
            THEN ri.`Hóa đơn`
        END
    ) AS `Số hóa đơn New`,

    /* ===== Doanh thu New ===== */
    SUM(
        CASE
            WHEN ri.`Loại đơn hàng` = 'New'
            THEN CAST(REPLACE(rp.`Khoản 1`, ',', '') AS DECIMAL(15,2))
            ELSE 0
        END
    ) AS `Doanh thu New`,

    /* ===== Doanh thu trung bình / học viên ===== */
    ROUND(
        SUM(
            CASE
                WHEN ri.`Loại đơn hàng` = 'New'
                THEN CAST(REPLACE(rp.`Khoản 1`, ',', '') AS DECIMAL(15,2))
                ELSE 0
            END
        )
        /
        NULLIF(
            COUNT(DISTINCT
                CASE
                    WHEN ri.`Loại đơn hàng` = 'New'
                    THEN ri.`Mã học viên`
                END
            ),
            0
        ),
        2
    ) AS `Doanh thu TB / học viên`

FROM recipt_infomation ri
LEFT JOIN recorded_payment rp
    ON rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
   AND rp.`Mã học viên`  = ri.`Mã học viên`

WHERE
    ri.`Tháng ghi nhận hóa đơn` <> ''
	and ri.`Chương trình` <> ''
GROUP BY
    ri.`Chương trình`,
    ri.`Tháng ghi nhận hóa đơn`,
    ri.`Năm ghi nhận hóa đơn`

ORDER BY
    ri.`Năm ghi nhận hóa đơn`,
    ri.`Tháng ghi nhận hóa đơn`,
    ri.`Chương trình`;



----------------------- Bảng 1:
SELECT 
    COUNT(DISTINCT ri.`Mã học viên`) AS `Số học viên mới`,
    ri.`Chương trình`,
    ri.`Tháng ghi nhận hóa đơn` AS `Tháng`,
    ri.`Năm ghi nhận hóa đơn` AS `Năm`
FROM 
    recipt_infomation ri
WHERE 
    ri.`Loại đơn hàng` = 'new'
    and ri.`Tháng ghi nhận hóa đơn` <> ""
GROUP BY 
    ri.`Chương trình`,
    ri.`Tháng ghi nhận hóa đơn`,
    ri.`Năm ghi nhận hóa đơn`
ORDER BY 
    ri.`Năm ghi nhận hóa đơn`,
    ri.`Tháng ghi nhận hóa đơn`;

------------------------ Bảng 2:
SELECT 
    COUNT(*) AS `Số hóa đơn New`,
    `Chương trình`,
    `Tháng ghi nhận hóa đơn` AS `Tháng`,
    `Năm ghi nhận hóa đơn` AS `Năm`
FROM 
    recipt_infomation
WHERE 
    `Loại đơn hàng` = 'New'
--         and `Tháng ghi nhận hóa đơn` = 2
--     and `Năm ghi nhận hóa đơn`=2025
GROUP BY 
    `Chương trình`,
    `Tháng ghi nhận hóa đơn`,
    `Năm ghi nhận hóa đơn`
ORDER BY 
    `Năm ghi nhận hóa đơn`,
    `Tháng ghi nhận hóa đơn`,
    `Chương trình`;

----------------------------------------- Bảng 3:
WITH payment_management AS (
    SELECT
        rp.`Ngày`,
        `Khoản 1` AS `Đã thu`,
        `Mã hóa đơn 1` AS `Hóa đơn`,
        `TVV` AS `Tư vấn viên`,
        MONTH(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Tháng`,
        YEAR(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Năm`,
        rp.`Mã học viên` AS `Mã học sinh`,
        rp.`Bên khác bán`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình`,
        ri.`Size`,
        ri.`Chương trình`,
        ri.`Loại đơn hàng`  -- thêm trường này để lọc New (nếu chưa có thì cần thêm)
    FROM recorded_payment rp 
    LEFT JOIN recipt_infomation ri 
        ON rp.`Mã học viên` = ri.`Mã học viên` 
        AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
)

SELECT
    SUM(CAST(REPLACE(pm.`Đã thu`, ',', '') AS DECIMAL(15,2))) AS `Doanh thu New`,
    pm.`Chương trình`,
    pm.`Tháng`,
    pm.`Năm`
FROM payment_management pm
WHERE pm.`Loại đơn hàng` = 'New'

    and `Tháng` = 1
    and `Năm`=2025
GROUP BY pm.`Chương trình`;

------------------------------ Bảng 4: 

WITH
-- ===== Bảng 3: Doanh thu New =====
payment_management AS (
    SELECT
        rp.`Ngày`,
        CAST(REPLACE(`Khoản 1`, ',', '') AS DECIMAL(15,2)) AS `Đã thu`,
        rp.`Mã hóa đơn 1` AS `Hóa đơn`,
        MONTH(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Tháng`,
        YEAR(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Năm`,
        ri.`Chương trình`,
        ri.`Loại đơn hàng`
    FROM recorded_payment rp
    LEFT JOIN recipt_infomation ri
        ON rp.`Mã học viên` = ri.`Mã học viên`
        AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
),

revenue_new AS (
    SELECT
        `Chương trình`,
        `Tháng`,
        `Năm`,
        SUM(`Đã thu`) AS `Doanh thu New`
    FROM payment_management
    WHERE `Loại đơn hàng` = 'New'
    GROUP BY `Chương trình`, `Tháng`, `Năm`
),

-- ===== Bảng 1: Số học viên mới =====
student_new AS (
    SELECT
        ri.`Chương trình`,
        ri.`Tháng ghi nhận hóa đơn` AS `Tháng`,
        ri.`Năm ghi nhận hóa đơn` AS `Năm`,
        COUNT(DISTINCT ri.`Mã học viên`) AS `Số học viên mới`
    FROM recipt_infomation ri
    WHERE ri.`Loại đơn hàng` = 'new'
      AND ri.`Tháng ghi nhận hóa đơn` <> ''
    GROUP BY
        ri.`Chương trình`,
        ri.`Tháng ghi nhận hóa đơn`,
        ri.`Năm ghi nhận hóa đơn`
)

-- ===== Bảng 4: Trung bình =====
SELECT
    r.`Chương trình`,
    r.`Tháng`,
    r.`Năm`,
    r.`Doanh thu New`,
    s.`Số học viên mới`,
    ROUND(
        r.`Doanh thu New` / NULLIF(s.`Số học viên mới`, 0),
        2
    ) AS `Doanh thu trung bình / học viên`
FROM revenue_new r
LEFT JOIN student_new s
    ON r.`Chương trình` = s.`Chương trình`
   AND r.`Tháng` = s.`Tháng`
   AND r.`Năm` = s.`Năm`
-- WHERE r.`Tháng` = 1
--   AND r.`Năm` = 2025
ORDER BY r.`Chương trình`;

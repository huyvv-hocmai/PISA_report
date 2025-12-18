SELECT
    ra.`Mã học viên`,
    ra.`Tên học viên`,

    /* Fix cứng chương trình */
    SUM(CASE WHEN rp.`Chương trình` = 'HT'   THEN 1 ELSE 0 END) AS `HT`,
    SUM(CASE WHEN rp.`Chương trình` = 'LT'   THEN 1 ELSE 0 END) AS `LT`,
    SUM(CASE WHEN rp.`Chương trình` = 'TA'   THEN 1 ELSE 0 END) AS `TA`,
    SUM(CASE WHEN rp.`Chương trình` = 'CODE' THEN 1 ELSE 0 END) AS `CODE`,

    /* ===== Đang học PISA ===== */
    SUM(
        CASE
            WHEN rp.`Tiến độ` < 1
             AND rp.`Tiến độ` > 0.001
             AND rp.Preserved = 0
            THEN 1 ELSE 0
        END
    ) AS `Đang học PISA`,
    SUM(
        CASE
            WHEN 
              rp.Preserved > 0
            THEN 1 ELSE 0
        END
    ) AS `Bảo lưu PISA`,
    SUM(
        CASE
            WHEN rp.`Tiến độ` = 1
            THEN 1 ELSE 0
        END
    ) AS ` Đã học PISA`

FROM receipt_all ra
JOIN receipt_progress rp
    ON ra.`Hóa đơn` = rp.HD
WHERE rp.`Mã học sinh` = 'SHN1-07-1027'
GROUP BY
    ra.`Mã học viên`,
    ra.`Tên học viên`;
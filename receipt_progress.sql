SELECT
    r.HD,

    /* Thông tin từ receipt */
    r.PTCM,
    r.`Mã học sinh`,
    r.`Tên học sinh`,
    r.`Lớp`,
    r.`Môn`,
    r.`Chương trình`,
    r.`Loại hình`,
    r.`Size`,
    r.`TVV`,
    r.`Số buổi học`,

    /* Đếm trạng thái */
    SUM(CASE WHEN s.`Trạng thái` = 'Planned'   THEN 1 ELSE 0 END) AS Planned,
    SUM(CASE WHEN s.`Trạng thái` = 'Completed' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN s.`Trạng thái` = 'Absent'    THEN 1 ELSE 0 END) AS Absent,
    SUM(CASE WHEN s.`Trạng thái` = 'Preserved' THEN 1 ELSE 0 END) AS Preserved,
    SUM(CASE WHEN s.`Trạng thái` = 'Stopped'   THEN 1 ELSE 0 END) AS Stopped,

    /* Chưa xếp lịch */
    r.`Số buổi học`
      - SUM(
            CASE 
                WHEN s.`Trạng thái` IN ('Planned','Completed','Absent','Preserved','Stopped')
                THEN 1 ELSE 0 
            END
        ) AS `Chưa xếp lịch`,

    /* Buổi đầu & Buổi cuối */
    MIN(
        CASE 
            WHEN s.`Ngày học` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
        END
    ) AS `Buổi đầu`,

    MAX(
        CASE 
            WHEN s.`Ngày học` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
        END
    ) AS `Buổi cuối`,

    /* ===== CỘT MỚI ===== */

    /* Số buổi còn lại */
    r.`Số buổi học`
      - SUM(CASE WHEN s.`Trạng thái` = 'Completed' THEN 1 ELSE 0 END)
      - SUM(CASE WHEN s.`Trạng thái` = 'Absent'    THEN 1 ELSE 0 END)
      - SUM(CASE WHEN s.`Trạng thái` = 'Stopped'   THEN 1 ELSE 0 END)
      AS `Số buổi còn lại`,

    /* Học phí còn lại */
    (
        r.`HP/ buổi 1` + r.`HP/ buổi 2`
    ) * (
        r.`Số buổi học`
        - SUM(CASE WHEN s.`Trạng thái` = 'Completed' THEN 1 ELSE 0 END)
        - SUM(CASE WHEN s.`Trạng thái` = 'Absent'    THEN 1 ELSE 0 END)
        - SUM(CASE WHEN s.`Trạng thái` = 'Stopped'   THEN 1 ELSE 0 END)
    ) AS `Học phí còn lại`,

    /* Hạn bảo lưu */
    DATE_ADD(
        MAX(
            CASE 
                WHEN s.`Ngày học` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
                THEN STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
            END
        ),
        INTERVAL 100 DAY
    ) AS `Hạn bảo lưu`

FROM (
    /* Receipt PISA */
    SELECT
        ri.`Hóa đơn`        AS HD,
        ri.PTCM,
        ri.`Mã học viên`   AS `Mã học sinh`,
        ri.`Tên học viên`  AS `Tên học sinh`,
        ri.`Lớp`,
        ri.`Môn học`       AS `Môn`,
        ri.`Chương trình`,
        ri.`Loại hình`,
        ri.`Size`,
        ri.`Tư vấn viên`   AS `TVV`,
        ri.`Số buổi học`,
        ri.`HP/ buổi 1`,
        ri.`HP/ buổi 2`
    FROM recipt_infomation ri
    WHERE ri.`Loại hình` = 'PISA'
      AND ri.`Hóa đơn` IS NOT NULL
) r
LEFT JOIN schedule s
    ON r.HD = s.`Hóa đơn`
GROUP BY
    r.HD,
    r.PTCM,
    r.`Mã học sinh`,
    r.`Tên học sinh`,
    r.`Lớp`,
    r.`Môn`,
    r.`Chương trình`,
    r.`Loại hình`,
    r.`Size`,
    r.`TVV`,
    r.`Số buổi học`,
    r.`HP/ buổi 1`,
    r.`HP/ buổi 2`;

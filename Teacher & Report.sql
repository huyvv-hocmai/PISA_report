-- Bảng 2 chung
WITH ca_fact AS (
    SELECT
        s.`Mã CVHT`,
        s.`Ngày học`,
        s.Ca,
        s.`Môn`,
        s.`Size`,
        COUNT(CASE WHEN s.`Trạng thái` = 'Completed' THEN 1 END) AS so_completed
    FROM schedule s
    WHERE
        STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND s.`Mã CVHT` IS NOT NULL
    GROUP BY
        s.`Mã CVHT`,
        s.`Ngày học`,
        s.Ca,
        s.`Môn`,
        s.`Size`
)

SELECT
    `Mã CVHT` AS CVHT,

    /* ===== Đếm CA theo số Completed ===== */
    COUNT(CASE WHEN so_completed = 1 THEN 1 END) AS `Ca 1 - 1`,
    COUNT(CASE WHEN so_completed = 2 THEN 1 END) AS `Ca 1 - 2`,
    COUNT(CASE WHEN so_completed = 3 THEN 1 END) AS `Ca 1 - 3`,
    COUNT(CASE WHEN so_completed = 4 THEN 1 END) AS `Ca 1 - 4`,

    /* ===== Đếm LƯỢT Completed theo Size ===== */
    SUM(CASE WHEN `Size` = '1 - 1' THEN so_completed ELSE 0 END) AS `Lượt 1 - 1`,
    SUM(CASE WHEN `Size` = '1 - 2' THEN so_completed ELSE 0 END) AS `Lượt 1 - 2`,
    SUM(CASE WHEN `Size` = '1 - 3' THEN so_completed ELSE 0 END) AS `Lượt 1 - 3`,
    SUM(CASE WHEN `Size` = '1 - 4' THEN so_completed ELSE 0 END) AS `Lượt 1 - 4`

FROM ca_fact
GROUP BY `Mã CVHT`
ORDER BY `Mã CVHT`;


-- Bảng 2 - 2:
WITH buffer AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        s.Ca,
        s.`Trạng thái`,
        s.`Mã CVHT`,
        s.PTCM,
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
                s.`Môn`,
                s.`Size`
        ) AS `SỐ lượt hoàn thành`
    FROM schedule s
    WHERE STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
      AND STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y') < '2026-01-01'
), tmp AS (
    SELECT DISTINCT
        `Mã CVHT`,
        `Ngày học`,
        Ca,
        `Môn`,
        Size,
        `SỐ lượt hoàn thành`
    FROM buffer
)

SELECT
    `Mã CVHT` AS CVHT,

    COUNT(CASE 
        WHEN `SỐ lượt hoàn thành` = 1 THEN 1 
    END) AS `Ca 1 - 1`,

    COUNT(CASE 
        WHEN `SỐ lượt hoàn thành` = 2 THEN 1 
    END) AS `Ca 1 - 2`,

    COUNT(CASE 
        WHEN `SỐ lượt hoàn thành` = 3 THEN 1 
    END) AS `Ca 1 - 3`,

    COUNT(CASE 
        WHEN `SỐ lượt hoàn thành` = 4 THEN 1 
    END) AS `Ca 1 - 4`

FROM tmp
GROUP BY `Mã CVHT`
ORDER BY `Mã CVHT`;


-- Bảng 2 - 1:
SELECT 
    COALESCE(`Mã CVHT`, 'SUM') AS `CVHT`,
    SUM(CASE WHEN `Size` = '1 - 1' THEN 1 ELSE 0 END) AS `Lượt 1 - 1`,
    SUM(CASE WHEN `Size` = '1 - 2' THEN 1 ELSE 0 END) AS `Lượt 1 - 2`,
    SUM(CASE WHEN `Size` = '1 - 3' THEN 1 ELSE 0 END) AS `Lượt 1 - 3`,
    SUM(CASE WHEN `Size` = '1 - 4' THEN 1 ELSE 0 END) AS `Lượt 1 - 4`
FROM (
    -- Phần chi tiết: học sinh duy nhất theo CVHT và Size, chỉ lấy Completed
    SELECT 
        `Mã CVHT`,
        `Mã HS`,
        `Size`
    FROM schedule
    WHERE 
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND `Mã CVHT` IS NOT NULL
        AND `Trạng thái` = 'Completed'                  -- Chỉ lấy Completed
        AND `Size` IN ('1 - 1', '1 - 2', '1 - 3', '1 - 4')

    UNION ALL

    -- Phần tổng: dùng NULL để tạo dòng SUM
    SELECT 
        NULL AS `Mã CVHT`,
        `Mã HS`,
        `Size`
    FROM schedule
    WHERE 
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND `Mã CVHT` IS NOT NULL
        AND `Trạng thái` = 'Completed'                  -- Chỉ lấy Completed
        AND `Size` IN ('1 - 1', '1 - 2', '1 - 3', '1 - 4')
) AS data
GROUP BY `Mã CVHT`
ORDER BY
    CASE WHEN `Mã CVHT` IS NULL THEN 0 ELSE 1 END,  -- SUM lên đầu
    `Mã CVHT` ASC;
    
-- 2.1: Cách đúng:
WITH
-- 1. Danh sách CVHT
cvht_list AS (
    SELECT DISTINCT `Mã CVHT`
    FROM schedule
    WHERE 
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND `Mã CVHT` IS NOT NULL
),

-- 2. Danh sách Size (động, có 1-5 thì tự lên)
size_list AS (
    SELECT DISTINCT `Size`
    FROM schedule
    WHERE 
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
),

-- 3. Dữ liệu Completed
fact AS (
    SELECT 
        `Mã CVHT`,
        `Size`
    FROM schedule
    WHERE 
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND `Trạng thái` = 'Completed'
)

SELECT
    c.`Mã CVHT` AS `CVHT`,
    s.`Size`,
    COUNT(f.`Size`) AS `Số lượng`
FROM cvht_list c
CROSS JOIN size_list s
LEFT JOIN fact f
    ON f.`Mã CVHT` = c.`Mã CVHT`
   AND f.`Size` = s.`Size`
GROUP BY
    c.`Mã CVHT`,
    s.`Size`
ORDER BY
    c.`Mã CVHT`,
    s.`Size`;

    




-- Bảng 1 v2: Thêm chiều
WITH stats AS (
    SELECT  
        `PTCM`,
        MONTH(STR_TO_DATE(`Ngày học`, '%d/%m/%Y')) AS thang,
        YEAR(STR_TO_DATE(`Ngày học`, '%d/%m/%Y')) AS nam,

        COUNT(DISTINCT `Mã HS`) AS so_hs_active,
        COUNT(*) AS so_luot_phu_trach,

        SUM(CASE WHEN `Trạng thái` = 'Completed' THEN 1 ELSE 0 END) AS Completed,
        SUM(CASE WHEN `Trạng thái` = 'Planned' THEN 1 ELSE 0 END) AS Planned,
        SUM(CASE WHEN `Trạng thái` = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
        SUM(CASE WHEN `Trạng thái` = 'Absent' THEN 1 ELSE 0 END) AS Absent,
        SUM(CASE WHEN `Trạng thái` = 'Preserved' THEN 1 ELSE 0 END) AS Preserved,
        SUM(CASE WHEN `Trạng thái` = 'Stopped' THEN 1 ELSE 0 END) AS Stopped
    FROM schedule
    WHERE  
        `PTCM` IS NOT NULL
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') IS NOT NULL
    GROUP BY 
        `PTCM`,
        nam,
        thang
),

total AS (
    SELECT  
        'SUM' AS PTCM,
        thang,
        nam,

        SUM(so_hs_active) AS so_hs_active,
        SUM(so_luot_phu_trach) AS so_luot_phu_trach,
        SUM(Completed) AS Completed,
        SUM(Planned) AS Planned,
        SUM(Cancelled) AS Cancelled,
        SUM(Absent) AS Absent,
        SUM(Preserved) AS Preserved,
        SUM(Stopped) AS Stopped
    FROM stats
    WHERE 
        nam IS NOT NULL
        AND thang IS NOT NULL
    GROUP BY nam, thang
),

detail AS (
    SELECT  
        `PTCM`,
        thang,
        nam,

        so_hs_active,
        so_luot_phu_trach,
        Completed,
        Planned,
        Cancelled,
        Absent,
        Preserved,
        Stopped
    FROM stats
    WHERE 
        `PTCM` <> ''
        AND nam IS NOT NULL
        AND thang IS NOT NULL
)

SELECT *
FROM detail

UNION ALL

SELECT *
FROM total

ORDER BY 
    nam,
    thang,
    PTCM;


-- Bảng 1
WITH stats AS (
    SELECT  
        `PTCM`,
        COUNT(DISTINCT `Mã HS`) AS so_hs_active,
        COUNT(*) AS so_luot_phu_trach,
        SUM(CASE WHEN `Trạng thái` = 'Completed' THEN 1 ELSE 0 END) AS Completed,
        SUM(CASE WHEN `Trạng thái` = 'Planned' THEN 1 ELSE 0 END) AS Planned,
        SUM(CASE WHEN `Trạng thái` = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
        SUM(CASE WHEN `Trạng thái` = 'Absent' THEN 1 ELSE 0 END) AS Absent,
        SUM(CASE WHEN `Trạng thái` = 'Preserved' THEN 1 ELSE 0 END) AS Preserved,
        SUM(CASE WHEN `Trạng thái` = 'Stopped' THEN 1 ELSE 0 END) AS Stopped
    FROM schedule
    WHERE  
        STR_TO_DATE(`Ngày học`, '%d/%m/%Y') >= '2025-12-01'
        AND STR_TO_DATE(`Ngày học`, '%d/%m/%Y') < '2026-01-01'
        AND `PTCM` IS NOT NULL
        AND `Trạng thái` IN ('Completed','Planned','Cancelled','Absent','Preserved','Stopped')
    GROUP BY `PTCM`
),
total AS (
    SELECT  
        'SUM' AS PTCM_sort,
        'SUM' AS PTCM,
        SUM(so_hs_active) AS so_hs_active,
        SUM(so_luot_phu_trach) AS so_luot_phu_trach,
        SUM(Completed) AS Completed,
        SUM(Planned) AS Planned,
        SUM(Cancelled) AS Cancelled,
        SUM(Absent) AS Absent,
        SUM(Preserved) AS Preserved,
        SUM(Stopped) AS Stopped
    FROM stats
),
detail AS (
    SELECT  
        `PTCM` AS PTCM_sort,
        `PTCM`,
        so_hs_active,
        so_luot_phu_trach,
        Completed,
        Planned,
        Cancelled,
        Absent,
        Preserved,
        Stopped
    FROM stats
)

SELECT *
FROM detail

UNION ALL

SELECT *
FROM total
ORDER BY PTCM_sort;


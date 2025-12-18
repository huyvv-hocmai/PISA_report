-- Bảng 3:
WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        s.Ca,
        s.`Trạng thái`,
        s.`Mã CVHT`,
        r.`Chương trình`,
        s.`Môn`,
        s.`Size`,
        DAYOFWEEK(str_to_date(s.`Ngày học`, '%d/%m/%Y')) AS 'Thứ'  -- Ngày trong tuần
    FROM schedule s
    JOIN receipt r ON s.`Hóa đơn` = r.HD
    WHERE s.`Trạng thái` <> 'Preserved'
)
SELECT
    t.`Môn`,  -- Môn học
    t.Size,  -- Kích thước
    -- Công suất ca KH: Tổng số lượt học theo Ca / Tổng số giáo viên
    (COUNT(DISTINCT t.`Mã CVHT`) * 4) / NULLIF(COUNT(DISTINCT t.`Mã CVHT`), 0) AS `Công suất ca KH`,
    -- Tổng lượt TT: Tổng số lượt hoàn thành
    (SELECT SUM(t2.`Trạng thái` = 'Completed') 
     FROM tmp t2
     WHERE t2.`Môn` = t.`Môn`
       AND t2.`Size` = t.`Size`
       AND t2.`Trạng thái` = 'Completed') AS `Tổng số lượt TT`,
    -- Số ca = Tổng bản ghi (hoặc Số GV nếu bạn muốn tính số ca theo giáo viên)
    COUNT(*) AS `Số ca`,
    -- Công suất TT = Số ca / Tổng lượt TT
    NULLIF(COUNT(*), 0) / NULLIF(
        (SELECT SUM(t2.`Trạng thái` = 'Completed') 
         FROM tmp t2
         WHERE t2.`Môn` = t.`Môn`
           AND t2.`Size` = t.`Size`
           AND t2.`Trạng thái` = 'Completed'), 0) AS `Công suất TT`,
    -- Cột theo tuần (7 ngày) từ 30/10/2025
    FLOOR(DATEDIFF(STR_TO_DATE(t.`Ngày học`, '%d/%m/%Y'), STR_TO_DATE('30/10/2025', '%d/%m/%Y')) / 7) + 1 AS `Tuần`
FROM tmp t
WHERE 
    t.Size = '1 - 4' 
    AND t.`Môn` = 'V'
    -- Lọc theo Tuần "30/10/2025 - 5/11/2025"
    AND FLOOR(DATEDIFF(STR_TO_DATE(t.`Ngày học`, '%d/%m/%Y'), STR_TO_DATE('30/10/2025', '%d/%m/%Y')) / 7) + 1 = 1
GROUP BY
    t.`Môn`, t.Size, `Tuần`  -- Nhóm theo Tuần, Môn, và Size
ORDER BY 
    t.`Môn`, t.Size, `Tuần`;  -- Sắp xếp theo Tuần


-- Bảng 2:
WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        DAYOFWEEK(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) AS `Thứ`,  -- Ngày trong tuần
        s.Ca,  -- Ca học
        s.`Trạng thái`,
        s.`Mã CVHT`,
        r.`Chương trình`,
        s.`Môn`,
        s.`Size`
    FROM schedule s
    JOIN receipt r ON s.`Hóa đơn` = r.HD
    WHERE s.`Trạng thái` <> 'Preserved'
      AND STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
          BETWEEN STR_TO_DATE('08/12/2025', '%d/%m/%Y')
              AND STR_TO_DATE('15/12/2025', '%d/%m/%Y')
)
SELECT
    t.`Môn`,  -- Môn học
    t.Ca,  -- Ca học
    t.Size,  -- Kích thước
    t.`Ngày học`,  -- Ngày học
    t.`Thứ`,  -- Ngày trong tuần
    -- Số GV (Số lượng giáo viên)
    COUNT(DISTINCT t.`Mã CVHT`) AS `Số GV`,
    -- Lượt trống (calculated based on Số GV and Số lượt kế hoạch)
    CASE 
        WHEN COUNT(DISTINCT t.`Mã CVHT`) = 0 THEN 0
        ELSE 
            COUNT(DISTINCT t.`Mã CVHT`) * 4 - 
            (SELECT COUNT(*) 
             FROM tmp t2
             WHERE t2.`Ngày học` = t.`Ngày học`
               AND t2.Ca = t.Ca
               AND t2.`Môn` = t.`Môn`
               AND t2.`Size` = t.`Size`)  -- Số lượt kế hoạch
    END AS `Lượt trống`
FROM tmp t
GROUP BY
    t.`Môn`, t.Ca, t.Size, t.`Ngày học`, t.`Thứ`
ORDER BY 
    t.`Môn`, t.Ca, t.Size, t.`Ngày học`, t.`Thứ`;



-- Bảng 1:
WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        DAYOFWEEK(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) AS `Thứ`,  -- Day of the week (1 = Sunday, 2 = Monday, ...)
        s.Ca,  -- Class period
        s.`Trạng thái`,
        s.`Mã CVHT`,
        s.PTCM,
        r.`Chương trình`,
        s.`Môn`,
        s.`Size`
    FROM schedule s
    JOIN receipt r 
        ON s.`Hóa đơn` = r.HD
    WHERE s.`Trạng thái` <> 'Preserved'
    AND STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
        BETWEEN STR_TO_DATE('08/12/2025', '%d/%m/%Y')
            AND STR_TO_DATE('15/12/2025', '%d/%m/%Y')
)
-- Pivot the table to get counts based on Thứ (day of the week), Môn (subject), and Ca (period)
SELECT
    t.`Môn`, 
    t.Ca,  -- Add Ca as part of the result
    SUM(CASE WHEN t.`Thứ` = 1 THEN 1 ELSE 0 END) AS `Chủ nhật`,  -- Count for Chủ nhật (Sunday)
    SUM(CASE WHEN t.`Thứ` = 2 THEN 1 ELSE 0 END) AS `Thứ 2`,  -- Count for Thứ 2
    SUM(CASE WHEN t.`Thứ` = 3 THEN 1 ELSE 0 END) AS `Thứ 3`,  -- Count for Thứ 3
    SUM(CASE WHEN t.`Thứ` = 4 THEN 1 ELSE 0 END) AS `Thứ 4`,  -- Count for Thứ 4
    SUM(CASE WHEN t.`Thứ` = 5 THEN 1 ELSE 0 END) AS `Thứ 5`,  -- Count for Thứ 5
    SUM(CASE WHEN t.`Thứ` = 6 THEN 1 ELSE 0 END) AS `Thứ 6`,  -- Count for Thứ 6
    SUM(CASE WHEN t.`Thứ` = 7 THEN 1 ELSE 0 END) AS `Thứ 7`   -- Count for Thứ 7
FROM tmp t
WHERE 
    t.`Trạng thái` = 'Completed'   -- Only count completed statuses
    AND t.`Môn` = 'T'  -- Only for Môn "T"
GROUP BY t.`Môn`, t.Ca  -- Group by both Môn (subject) and Ca (class period)
ORDER BY t.`Môn`, t.Ca;
 
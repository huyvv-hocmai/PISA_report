-- version đúng
WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        DAYOFWEEK(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) AS `Thứ`,
        s.Ca,
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
-- Create new table with Mã HS & Môn and count of occurrences
SELECT 
    CONCAT(t.`Mã HS`, t.`Môn`) AS `Mã HS & Môn`,  -- Combine Mã HS and Môn
    COUNT(*) AS `Số lượng`  -- Count the occurrences
FROM tmp t
GROUP BY t.`Mã HS`, t.`Môn`;  -- Group by Mã HS and Môn




WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        DAYOFWEEK(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) AS `Thứ`,
        s.Ca,
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
),
base AS (
    SELECT DISTINCT
        `Mã CVHT`,     -- F
        `Ngày học`,    -- C
        Ca,            -- D
        `Môn`,         -- J
        `Size`         -- K
    FROM tmp
    WHERE `Trạng thái` <> 'Preserved'
)
SELECT 
    b.*,
    -- Cố số lượt hoàn thành
    (SELECT COUNT(*) 
     FROM tmp t
     WHERE t.`Mã CVHT` = b.`Mã CVHT`
       AND t.`Ngày học` = b.`Ngày học`
       AND t.Ca = b.Ca
       AND t.`Môn` = b.`Môn`
       AND t.`Size` = b.`Size`
       AND t.`Trạng thái` = 'Completed') AS `Cố số lượt hoàn thành`,
    -- Số lượt kế hoạch
    (SELECT COUNT(*) 
     FROM tmp t
     WHERE t.`Mã CVHT` = b.`Mã CVHT`
       AND t.`Ngày học` = b.`Ngày học`
       AND t.Ca = b.Ca
       AND t.`Môn` = b.`Môn`
       AND t.`Size` = b.`Size`) AS `Số lượt kế hoạch`,
    -- Số lượt kế hoạch - Số lượt hoàn thành (difference)
    ((SELECT COUNT(*) 
      FROM tmp t
      WHERE t.`Mã CVHT` = b.`Mã CVHT`
        AND t.`Ngày học` = b.`Ngày học`
        AND t.Ca = b.Ca
        AND t.`Môn` = b.`Môn`
        AND t.`Size` = b.`Size`) 
    - 
    (SELECT COUNT(*) 
     FROM tmp t
     WHERE t.`Mã CVHT` = b.`Mã CVHT`
       AND t.`Ngày học` = b.`Ngày học`
       AND t.Ca = b.Ca
       AND t.`Môn` = b.`Môn`
       AND t.`Size` = b.`Size`
       AND t.`Trạng thái` = 'Completed')) AS `Số lượt còn lại`
FROM base b;

--=> Version xịn hơn
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
        s.`Size`
    FROM schedule s
    JOIN receipt r ON s.`Hóa đơn` = r.HD
    WHERE s.`Trạng thái` <> 'Preserved'
      AND STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')
          BETWEEN STR_TO_DATE('08/12/2025', '%d/%m/%Y')
              AND STR_TO_DATE('15/12/2025', '%d/%m/%Y')
)

SELECT
    t.`Mã CVHT`,
    t.`Ngày học`,
    t.Ca,
    t.`Môn`,
    t.`Size`,

    SUM(t.`Trạng thái` = 'Completed') AS `Số lượt hoàn thành`,
    COUNT(*)                          AS `Số lượt kế hoạch`,
    COUNT(*) - SUM(t.`Trạng thái` = 'Completed') AS `Số lượt còn lại`

FROM tmp t
GROUP BY
    t.`Mã CVHT`,
    t.`Ngày học`,
    t.Ca,
    t.`Môn`,
    t.`Size`;

----


WITH tmp AS (
    SELECT 
        s.`Mã HS`,
        s.`Hóa đơn`,
        s.`Ngày học`,
        DAYOFWEEK(STR_TO_DATE(s.`Ngày học`, '%d/%m/%Y')) AS `Thứ`,
        s.Ca,
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

WITH base as (
SELECT DISTINCT
    `Mã CVHT`,     -- F
    `Ngày học`,    -- C
    Ca,            -- D
    `Môn`,         -- J
    `Size`         -- K
FROM tmp
WHERE `Trạng thái` <> 'Preserved')  ;



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



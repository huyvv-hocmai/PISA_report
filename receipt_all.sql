With receipt_all as(
select * from (
SELECT 
    ri.`Hóa đơn`,
    ri.`Ngày`,
    ri.`Mã học viên`,
    ri.`Tên học viên`,
    ri.`Loại đơn hàng` AS `Loại HV`,
    FLOOR(
        (DAY(STR_TO_DATE(ri.`Ngày`, '%d/%m/%Y')) + 
         CASE WEEKDAY(CONCAT(YEAR(STR_TO_DATE(ri.`Ngày`, '%d/%m/%Y')), '-', 
                            MONTH(STR_TO_DATE(ri.`Ngày`, '%d/%m/%Y')), '-01'))
           WHEN 0 THEN 1   -- Thứ Hai → 1
           WHEN 1 THEN 2   -- Thứ Ba → 2
           WHEN 2 THEN 3
           WHEN 3 THEN 4
           WHEN 4 THEN 5
           WHEN 5 THEN 6
           WHEN 6 THEN 7   -- Chủ Nhật → 7
         END 
         - 2) / 7
    ) + 1 AS `Tuần`
FROM recipt_infomation ri
WHERE ri.`Ngày` IS NOT NULL and ri.`Hóa đơn`  is not NULL ) as a)
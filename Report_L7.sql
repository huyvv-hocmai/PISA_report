-- v2: Thêm chiều Lớp, Size
WITH payment_management AS (
    SELECT 
        rp.`Ngày`,
        REPLACE(`Khoản 1`, ',', '') AS "Đã thu",  -- Loại bỏ dấu phẩy
        `Mã hóa đơn 1` AS "Hóa đơn",
        `TVV` AS "Tư vấn viên",
        MONTH(STR_TO_DATE(IFNULL(rp.`Ngày`, '01/01/1900'), '%d/%m/%Y')) AS `Tháng`,  -- Xử lý giá trị trống bằng '01/01/1900'
        YEAR(STR_TO_DATE(IFNULL(rp.`Ngày`, '01/01/1900'), '%d/%m/%Y')) AS `Năm`,  -- Xử lý giá trị trống bằng '01/01/1900'
        rp.`Mã học viên` AS "Mã học sinh",
        rp.`Bên khác bán`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình`,
        ri.`Size`,
        ri.`Chương trình`,
        ri.`Loại đơn hàng`  -- Thêm "Loại đơn hàng"
    FROM recorded_payment rp 
    LEFT JOIN recipt_infomation ri 
        ON rp.`Mã học viên` = ri.`Mã học viên` 
        AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
)
SELECT 
    rp.`Tháng`, 
    rp.`Năm`, 
    ri.`Chương trình`,  
    ri.`Loại đơn hàng`,  
    rp.`Lớp`,  -- Thêm "Lớp"
    rp.`Size`,  -- Thêm "Size"
    rp.`Môn học`,  -- Thêm "Môn học"
    COUNT(DISTINCT CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1', 'THITHU') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN rp.`Mã học sinh`
        ELSE NULL END) AS "Số học sinh unique",
    SUM(CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN CAST(rp.`Đã thu` AS DECIMAL(10,2))  
        ELSE 0 END) AS "Doanh thu",
    -- Tính giá trị đơn hàng trung bình (Doanh thu / Số học sinh unique)
    SUM(CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN CAST(rp.`Đã thu` AS DECIMAL(10,2))  
        ELSE 0 END) / 
    COUNT(DISTINCT CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1', 'THITHU') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN rp.`Mã học sinh`
        ELSE NULL END) AS "Giá trị đơn hàng TB"
FROM payment_management rp
LEFT JOIN recipt_infomation ri  
    ON rp.`Mã học sinh` = ri.`Mã học viên`
    AND rp.`Hóa đơn` = ri.`Hóa đơn`
WHERE rp.`Chương trình` IS NOT NULL  -- Lọc ra các chương trình không rỗng
GROUP BY rp.`Tháng`, rp.`Năm`, ri.`Chương trình`, ri.`Loại đơn hàng`, rp.`Lớp`, rp.`Size`, rp.`Môn học`  -- Thêm "Lớp", "Size", "Môn học" vào GROUP BY
ORDER BY ri.`Loại đơn hàng`;  



-- v1: 
WITH payment_management AS (
    SELECT 
        rp.`Ngày`,
        REPLACE(`Khoản 1`, ',', '') AS "Đã thu",  -- Loại bỏ dấu phẩy
        `Mã hóa đơn 1` AS "Hóa đơn",
        `TVV` AS "Tư vấn viên",
        MONTH(STR_TO_DATE(IFNULL(rp.`Ngày`, '01/01/1900'), '%d/%m/%Y')) AS `Tháng`,  -- Xử lý giá trị trống bằng '01/01/1900'
        YEAR(STR_TO_DATE(IFNULL(rp.`Ngày`, '01/01/1900'), '%d/%m/%Y')) AS `Năm`,  -- Xử lý giá trị trống bằng '01/01/1900'
        rp.`Mã học viên` AS "Mã học sinh",
        rp.`Bên khác bán`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình`,
        ri.`Size`,
        ri.`Chương trình`,
        ri.`Loại đơn hàng`  -- Thêm "Loại đơn hàng"
    FROM recorded_payment rp 
    LEFT JOIN recipt_infomation ri 
        ON rp.`Mã học viên` = ri.`Mã học viên` 
        AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
)
SELECT 
    rp.`Tháng`, 
    rp.`Năm`, 
    ri.`Chương trình`,  
    ri.`Loại đơn hàng`,  
    COUNT(DISTINCT CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1', 'THITHU') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN rp.`Mã học sinh`
        ELSE NULL END) AS "Số học sinh unique",
    SUM(CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN CAST(rp.`Đã thu` AS DECIMAL(10,2))  
        ELSE 0 END) AS "Doanh thu",
    -- Tính giá trị đơn hàng trung bình (Doanh thu / Số học sinh unique)
    SUM(CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN CAST(rp.`Đã thu` AS DECIMAL(10,2))  
        ELSE 0 END) / 
    COUNT(DISTINCT CASE 
        WHEN ri.`Loại đơn hàng` NOT IN ('New', 'New1', 'THITHU') 
        AND ri.`Tháng ghi nhận hóa đơn` = rp.`Tháng`
        AND ri.`Năm ghi nhận hóa đơn` = rp.`Năm` THEN rp.`Mã học sinh`
        ELSE NULL END) AS "Giá trị đơn hàng TB"
FROM payment_management rp
LEFT JOIN recipt_infomation ri  
    ON rp.`Mã học sinh` = ri.`Mã học viên`
    AND rp.`Hóa đơn` = ri.`Hóa đơn`
-- WHERE ri.`Năm ghi nhận hóa đơn` = 2025  
WHERE rp.`Chương trình` is not null
GROUP BY rp.`Tháng`, rp.`Năm`, ri.`Chương trình`, ri.`Loại đơn hàng`  -- Thêm "Chương trình" và "Loại đơn hàng" vào GROUP BY
ORDER BY ri.`Loại đơn hàng`;  
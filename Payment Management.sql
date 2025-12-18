WITH payment_management AS (
SELECT 
    rp.`Ngày`,
    `Khoản 1` as "Đã thu",
    `Mã hóa đơn 1` as "Hóa đơn",
    `TVV` as "Tư vấn viên",
    MONTH(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Tháng`,
    YEAR(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS `Năm`,
    rp.`Mã học viên` as "Mã học sinh",
    rp.`Bên khác bán`,
    ri.`Lớp`,
    ri.`Môn học`,
    ri.`Loại hình`,
    ri.`Size`,
    ri.`Chương trình`
FROM recorded_payment rp left join recipt_infomation ri on `rp`.`Mã học viên` = ri.`Mã học viên` and rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
where rp.`Mã hóa đơn 1` is not null);
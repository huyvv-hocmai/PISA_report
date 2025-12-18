SELECT *
FROM (
    SELECT 
        ri.`Hóa đơn` AS HD,
        ri.`Ngày`,
        ri.`Mã học viên`,
        ri.`Tên học viên`,
        ri.`Loại đơn hàng`,
        ri.Note,
        ri.`Tư vấn viên`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình`,
        ri.`Size`,
        ri.`Chương trình`,
        ri.`Số buổi học`,
        ri.PTCM,
        ri.`HP/ buổi 1`
        ri.`HP/ buổi 2`,
    FROM recipt_infomation AS ri
    WHERE ri.`Loại hình` = 'PISA'
) AS receipt;
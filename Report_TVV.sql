-- V2: update thêm chiều mới
WITH payment_management AS (
    SELECT
        rp.`Ngày`,
        CAST(REPLACE(REPLACE(rp.`Khoản 1`, ',', ''), '.', '') AS DECIMAL(15,2)) AS da_thu,
        rp.`Mã hóa đơn 1` AS hoa_don,
        rp.`TVV` AS tu_van_vien,
        MONTH(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS thang,
        YEAR(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS nam,
        rp.`Mã học viên` AS ma_hoc_sinh,
        rp.`Bên khác bán`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình` AS loai_hinh,
        ri.`Size`,
        ri.`Chương trình`
    FROM recorded_payment rp
    LEFT JOIN recipt_infomation ri
        ON rp.`Mã học viên` = ri.`Mã học viên`
       AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
)

SELECT
    nam,
    thang,
    tu_van_vien,

    -- Các chiều mới
    `Môn học`,
    loai_hinh,
    `Size`,
    `Chương trình`,

    -- Total Amount
    SUM(da_thu) AS total_amount,

    -- No of Receipt (loại Supplementary)
    COUNT(DISTINCT hoa_don)
      - COUNT(DISTINCT CASE
            WHEN loai_hinh = 'Supplementary' THEN hoa_don
        END) AS no_of_receipt,

    -- Average Amount
    ROUND(
        SUM(da_thu) /
        NULLIF(
            COUNT(DISTINCT hoa_don)
              - COUNT(DISTINCT CASE
                    WHEN loai_hinh = 'Supplementary' THEN hoa_don
                END),
            0
        ),
        0
    ) AS average_amount

FROM payment_management
WHERE tu_van_vien <> ''
  AND nam IS NOT NULL
  AND thang IS NOT NULL

GROUP BY
    nam,
    thang,
    tu_van_vien,
    `Môn học`,
    loai_hinh,
    `Size`,
    `Chương trình`

ORDER BY
    nam,
    thang,
    tu_van_vien,
    `Môn học`,
    loai_hinh;




-- V1: Giống sheet
WITH payment_management AS (
    SELECT
        rp.`Ngày`,
        CAST(REPLACE(REPLACE(rp.`Khoản 1`, ',', ''), '.', '') AS DECIMAL(15,2)) AS da_thu,
        rp.`Mã hóa đơn 1` AS hoa_don,
        rp.`TVV` AS tu_van_vien,
        MONTH(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS thang,
        YEAR(STR_TO_DATE(rp.`Ngày`, '%d/%m/%Y')) AS nam,
        rp.`Mã học viên` AS ma_hoc_sinh,
        rp.`Bên khác bán`,
        ri.`Lớp`,
        ri.`Môn học`,
        ri.`Loại hình` AS loai_hinh,
        ri.`Size`,
        ri.`Chương trình`
    FROM recorded_payment rp
    LEFT JOIN recipt_infomation ri
        ON rp.`Mã học viên` = ri.`Mã học viên`
       AND rp.`Mã hóa đơn 1` = ri.`Hóa đơn`
    WHERE rp.`Mã hóa đơn 1` IS NOT NULL
)
SELECT
    tu_van_vien,

    -- Total Amount (SUMIFS)
    SUM(da_thu) AS total_amount,

    -- No of Receipt (COUNTIFS - Supplementary)
    COUNT(DISTINCT hoa_don)
      - COUNT(DISTINCT CASE
            WHEN loai_hinh = 'Supplementary' THEN hoa_don
        END) AS no_of_receipt,

    -- Average
    ROUND(
        SUM(da_thu) /
        NULLIF(
            COUNT(DISTINCT hoa_don)
              - COUNT(DISTINCT CASE
                    WHEN loai_hinh = 'Supplementary' THEN hoa_don
                END),
            0
        ),
        0
    ) AS average_amount,
    nam,
    thang

FROM payment_management
WHERE tu_van_vien <> '' and nam is not null and thang is not null
GROUP BY
    nam,
    thang,
    tu_van_vien
ORDER BY
    nam,
    thang,
    tu_van_vien;
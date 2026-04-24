use QuanLyCuaHang;
go

--trigger rollback khi ban hang vuot ton
create or alter trigger trg_BanHang_Rollback
on ChiTietHoaDon
after insert
as
begin
	set nocount on;
	begin try
		if exists (
			select 1
			from inserted as i
			where dbo.fn_TonKho (i.MaSanPham) < 0
		)
		begin
			raiserror(N'ban vuot ton kho - rollback toan bo',16,1);
			rollback transaction;
			return;
		end
	end try
	begin catch
		rollback transaction;
	end catch
end;

--nhap masanpham voi so luong 10 vao bang chitietnhaphang
insert into ChiTietNhapHang (MaNhapHang,MaSanPham, SoLuong)
values ('NH01A','SP01A', 10);

--kierm tra ket qua nhap hang
SELECT MaSanPham, SoLuong
FROM ChiTietNhapHang
WHERE MaSanPham = 'SP01A';

--kiem tra ket quan ban
SELECT MaSanPham, SoLuong
FROM ChiTietHoaDon
WHERE MaSanPham = 'SP01A';

--kiem tra ket quan tonkho
select dbo.fn_TonKho('SP01A') as SoLuongTon

--thuc hien ban san pham > san phan tonkho
insert into ChiTietHoaDon (MaHoaDon, MaSanPham, MaKhachHang, MaNhanVien, SoLuong, DonGia)
values ('HD03A', 'SP01A', 'KH01A', 'NV01A', 800, 40000);

select * from ChiTietHoaDon
where MaHoaDon like 'HD03A';

select dbo.fn_TonKho('SP01A') as SoLuongTon;

--thuc hien ban san pham < san phan tonkho
insert into ChiTietHoaDon (MaHoaDon, MaSanPham, MaKhachHang, MaNhanVien, SoLuong, DonGia)
values ('HD03A', 'SP01A', 'KH01A', 'NV01A', 3, 40000);

--kỉiem tra thong tin hoa don xem co ton tai hoa don 'HD03A' 
--neu ton tai --> hop le
--nguoc lai --> khong hoip le
select * from ChiTietHoaDon where MaHoaDon like 'HD03A';

--kiem tra san pham ton kho duoc cap nhat
select dbo.fn_TonKho('SP01A') as SoLuongTon;

--==================================================================================================

--triger rollback khi update gia bat thuong
create or alter trigger trg_SanPham_Rollback
on SanPham
after update
as 
begin
    set nocount on;

    if exists (
        select 1
        from inserted i
        join deleted d on i.MaSanPham = d.MaSanPham
        where i.DonGia > d.DonGia * 1.5
    )
    begin
        throw 50002, N'Tang gia qua muc cho phep',1;
    end
end;

--kiem tra gia san pham
select MaSanPham, DonGia from SanPham;

--tang gia san pham SP01A len 5 lan
update SanPham
set DonGia = DonGia * 5
where MaSanPham like 'SP01A';

--tang gia san pham SP01A len 1.2 lan
update SanPham
set DonGia = DonGia * 1.2
where MaSanPham like 'SP01A';

select MaSanPham, DonGia from SanPham
where MaSanPham like 'SP01A';

--=================================================================================


--trigger rollback khi thanh toan sai tien
CREATE OR ALTER TRIGGER trg_ThanhToan_Update_Check
ON ThanhToan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    --neu hoa don da hoan thanh --> khong update
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d 
            ON i.MaThanhToan = d.MaThanhToan
        WHERE d.TrangThaiThanhToan = N'Hoan Thanh'
    )
    BEGIN
        PRINT N'Ma thanh toan nay da hoan thanh thanh toan roi';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    --neu thanh toan thieu tien --> rollback
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon
        WHERE i.SoTien < hd.TongTien
    )
    BEGIN
        PRINT N'So tien thanh toan khong du';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    --neu thanh toan du tien --> cap nhat trang thai
    UPDATE tt
    SET TrangThaiThanhToan = N'Hoan Thanh'
    FROM ThanhToan tt
    JOIN inserted i 
        ON tt.MaThanhToan = i.MaThanhToan
    JOIN HoaDon hd 
        ON i.MaHoaDon = hd.MaHoaDon
    WHERE i.SoTien = hd.TongTien;

    --neu thanh toan thua tien --> cap nhat trang thai + in thi thua
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon
        WHERE i.SoTien > hd.TongTien
    )
    BEGIN

        --cap nhat trang thai
        UPDATE tt
        SET TrangThaiThanhToan = N'Hoan Thanh'
        FROM ThanhToan tt
        JOIN inserted i 
            ON tt.MaThanhToan = i.MaThanhToan
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon
        WHERE i.SoTien > hd.TongTien;

		--tinh tien thua
        DECLARE @TienThua DECIMAL(12,2);

        SELECT @TienThua = i.SoTien - hd.TongTien
        FROM inserted i
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon;

        PRINT N'So tien thua: ' 
              + CAST(@TienThua AS NVARCHAR);

    END;

END;

--thong tin hoa don dua thanh toan
select * from ThanhToan tt;

--thuc hien thanh toan hoa don co TrangThaiHoanThanh la 'Hoan Thanh'
UPDATE ThanhToan
SET SoTien = 40000
WHERE MaThanhToan = 'TT01A';

--thuc hien thanh toan hoa don co TrangThaiHoanThanh la 'Chua Hoan Thanh'
UPDATE ThanhToan
SET SoTien = 18000
WHERE MaThanhToan = 'TT02B';

--Trang thai sau khi thanh toan
select tt.MaThanhToan, tt.TrangThaiThanhToan from ThanhToan tt
where tt.MaThanhToan like 'TT02B';

--thuc hien thanh toan hoa don khong du tien so voi hoa don
UPDATE ThanhToan
SET SoTien = 1000
WHERE MaThanhToan = 'TT05E';

--Trang thai sau khi thanh toan
select tt.MaThanhToan, tt.TrangThaiThanhToan from ThanhToan tt
where tt.MaThanhToan like 'TT05E';

--thuc hien thanh toan hoa don voi so tien lon hon so voi hoa don
UPDATE ThanhToan
SET SoTien = 10000
WHERE MaThanhToan = 'TT05E';

--Trang thai sau khi thanh toan
select tt.MaThanhToan, tt.TrangThaiThanhToan from ThanhToan tt
where tt.MaThanhToan like 'TT05E';


--=======================================================================


--trigger kiem tra email
create or alter trigger trg_Email_KhachHang
on KhachHang
instead of insert
as
begin
	set nocount on;
	if exists (
		select Email
		from inserted
		group by Email
		having count(*) > 1
	)
	begin
		throw 50008, N'Email bi trung trong du lieu nhap',1;
	end

	if exists (
		select 1
		from inserted as i
		join KhachHang as kh on i.Email = kh.Email
	)
	begin
		throw 50009, N'Email da ton tai trong he thong',1;
	end

	insert into KhachHang
	select * from inserted;
end;

select * from KhachHang k;

--them khach hang co mail da ton tai
insert into KhachHang (MaKhachHang, TenKhachHang, SoDienThoai, Email, DiaChi)
values('KH012', 'Khach 21', '0921115121', 'kh1@mail.com','HCM');

--=================================================================================

--them nhan vien moi (>= 18 tuoi và < 65 tuoi)
create or alter trigger trg_CheckNhanVien
on NhanVien
instead of insert
as
begin
	set nocount on;
	begin try
		if exists (
			select 1 from inserted as i
			join NhanVien as nv on i.MaNhanVien = nv.MaNhanVien
		)
		begin
			raiserror(N'Ma nhan vien da ton tai',16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted as i
			join NhanVien as nv on i.SoDienThoai = nv.SoDienThoai
		)
		begin
			raiserror(N'SO dien thoai da ton tai',16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted as i
			join NhanVien as nv on i.Email = nv.Email
		)
		begin
			raiserror(N'Email da ton tai',16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted as i
			where datediff(year, NgaySinh, NgayVaoLam) < 18
		)
		begin
			raiserror(N'Nhan vien chu du 18 tuoi', 16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted as i
			where datediff(year, NgaySinh, NgayVaoLam) > 65
		)
		begin
			raiserror(N'Nhan vien co tuoi qua cao de lam viec', 16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted
			where Luong < 0
		)
		begin
			raiserror(N'Luong khong hop le', 16,1);
			rollback;
			return;
		end

		insert into NhanVien (MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
		select MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong
		from inserted
	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;


--danh sach nhan vien
select * from NhanVien;

--them nhan vien co MaNhanVien trung
insert into NhanVien(MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
values ('NV20T', 'Tran Minh Cuong', '0923435353', 'tmc@mail.com','Manager', '2002-06-30', getdate(),2000);

--them nhan vien duoi 18 tuoi
insert into NhanVien(MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
values ('NV21T', 'Tran Minh Cuong', '0923435353', 'tmc@mail.com','Manager', '2022-06-30', getdate(),2000);

--them nhan vien tren 65 tuoi
insert into NhanVien(MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
values ('NV21T', 'Tran Minh Cuong', '0923435353', 'tmc@mail.com','Manager', '1945-06-30', getdate(),2000);

--them nhan vien
insert into NhanVien(MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
values ('NV21T', 'Tran Minh Cuong', '0923435353', 'tmc@mail.com','Manager', '2000-06-30', getdate(),2000);

--kiem tra nhan vien
select * from NhanVien nv
where nv.MaNhanVien like 'NV21T';
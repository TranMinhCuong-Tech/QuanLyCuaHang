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
    -- neu tang thai thanh toan da hoan thanh --> khong update
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

    -- kiem tra so tien can thanh toan
    -- neu thieu tien
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

    --  neu so tien thanh toan dung --> cap nhat trang thai hoan thanh
    UPDATE tt
    SET TrangThaiThanhToan = N'Hoan Thanh'
    FROM ThanhToan tt
    JOIN inserted i 
        ON tt.MaThanhToan = i.MaThanhToan
    JOIN HoaDon hd 
        ON i.MaHoaDon = hd.MaHoaDon
    WHERE i.SoTien = hd.TongTien;

    -- neu so tien lon hon --> in ra tien thua
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon
        WHERE i.SoTien > hd.TongTien
    )
    BEGIN
        DECLARE @TienThua DECIMAL(12,2);

        SELECT @TienThua = i.SoTien - hd.TongTien
        FROM inserted i
        JOIN HoaDon hd 
            ON i.MaHoaDon = hd.MaHoaDon;

        PRINT N'So tien thua: ' + CAST(@TienThua AS NVARCHAR);
    END;

END;

--thong tin hoa don dua thanh toan
select * from ThanhToan tt
where TrangThaiThanhToan like 'Chua Hoan Thanh';



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

--them nhan vien moi (>= 18 tuoi)
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
			select 1 from inserted
			where datediff(year, NgaySinh, getdate()) < 18
				or datediff(year, NgaySinh, getdate()) > 65
		)
		begin
			raiserror(N'TUoi nhan vien khong hop le', 16, 1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted as i
			where datediff(year, NgaySinh, NgayVaoLam) < 18
		)
		begin
			raiserror(N'Nhan vien chu du 18 tuo khi vao lam', 16,1);
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

--trigger kiem tra danh muc
create or alter trigger trg_DanhMuc_Check
on DanhMuc
instead of insert
as begin
	set nocount on
	begin try
		if exists (
			select 1
			from inserted as i
			join DanhMuc as dm on i.TenDanhMuc = dm.MaDanhMuc
		)
		begin
			raiserror(N'Ten danh muc da ton tai',16, 1);
			rollback;
			return;
		end

		insert into DanhMuc
		select * from inserted;

	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

--trigger them nha cung cap
create or alter trigger trg_NCC_Check
on NhaCungCap
instead of insert
as
begin
	set nocount on;
	 begin try
		if exists (
			select 1 from inserted
			where Email not like '%@%.%'
		)
		begin
			raiserror(N'Email khong hop le', 16,1);
			rollback;
			return;
		end

		if exists (
			select 1 from inserted
			where len(SoDienThoai) <> 10
		)
		begin
			raiserror(N'So dien thoai khong hop le', 16, 1)
			rollback;
			return;
		end

		insert into NhaCungCap
		select * from inserted;

	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

--trigger nhap hang
create or alter trigger trg_NhaHang_Check
on NhapHang
instead of insert
as
begin
	set nocount on;
	begin try
		if exists (
			select 1 from inserted
			where NgayNhap > getdate()
		)
		begin
			raiserror(N'Ngay nhap hang khong hop le', 16,1);
			rollback;
			return;
		end

		if exists(
			select 1 from inserted as i
			left join NhaCungCap as ncc on i.MaNhaCungCap = ncc.MaNhaCungCap
			where ncc.MaNhaCungCap is null
		)
		begin
			raiserror(N'Nha cung cap khong ton tai', 16,1);
			rollback;
			return;
		end

		insert into NhapHang
		select * from inserted;

	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;
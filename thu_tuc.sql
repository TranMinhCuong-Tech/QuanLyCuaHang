use QuanLyCuaHang;
go

CREATE FUNCTION dbo.fn_TonKho (@MaSanPham char(10))
RETURNS INT
AS
BEGIN
    DECLARE @Nhap INT = 0, @Ban INT = 0;

    SELECT @Nhap = ISNULL(SUM(SoLuong),0)
    FROM ChiTietNhapHang
    WHERE MaSanPham = @MaSanPham;

    SELECT @Ban = ISNULL(SUM(SoLuong),0)
    FROM ChiTietHoaDon
    WHERE MaSanPham = @MaSanPham;

    RETURN (@Nhap - @Ban);
END;
GO 

select * from ChiTietNhapHang as ctnh
where ctnh.MaSanPham like 'SP01A';

select * from ChiTietHoaDon as cthd
where cthd.MaSanPham like 'SP01A';

select dbo.fn_TonKho('SP01A') as TonKho
from ChiTietNhapHang
where MaSanPham like 'SP01A';


--====================================================================


--thu tuc ban hang
create procedure sp_BanHang
    @MaHoaDon char(10),
    @MaKhachHang char(10),
    @MaNhanVien char(10),
    @MaSanPham char(10),
    @SoLuong int
as
begin
    set nocount on;
    set xact_abort on;
    set transaction isolation level serializable;

    begin tran;
    begin try
        declare @Ton int, @Gia decimal(12,2);
        select @Ton = dbo.fn_TonKho(@MaSanPham);

        if @Ton < @SoLuong
            throw 50001, N'Khong du hang', 1;

        select @Gia = DonGia 
        from SanPham
        where MaSanPham = @MaSanPham;

        insert into HoaDon (MaHoaDon, MaKhachHang, MaNhanVien, MaSanPham, NgayLap, SoLuong, DonGia, TongTien)
        values (@MaHoaDon, @MaKhachHang, @MaNhanVien, @MaSanPham, getdate(), @SoLuong, @Gia, @SoLuong * @Gia);

        commit;
    end try
    begin catch
        rollback;
        print error_message();
    end catch
end;

EXEC sp_BanHang 
    'HD010', 'KH01A', 'NV04D', 
    'SP05E', 10;

EXEC sp_BanHang 
    'HD010', 'KH01A', 'NV04D', 
    'SP05E', 1000;

SELECT DISTINCT MaSanPham
FROM HoaDon
WHERE MaKhachHang = 'KH01A';

--==========================================================

--thu tuc nhap hang
create or alter procedure sp_NhapHang
    @MaNhapHang char(10),
    @MaKho char(10),
    @MaNhanVien char(10),
    @MaNCC char(10),
    @MaSanPham char(10),
    @SoLuong int,
    @DonGia decimal(12,2)
as
begin
    set nocount on;
    begin tran;

    begin try
        insert into NhapHang (MaNhapHang, MaKho, MaNhanVien, MaNhaCungCap, MaSanPham, NgayNhap, SoLuong)
        values (@MaNhapHang, @MaKho, @MaNhanVien, @MaNCC, @MaSanPham, getdate(), @SoLuong);

        insert into ChiTietNhapHang ( MaNhapHang,MaSanPham, SoLuong, DonGiaNhapHang )
        values (@MaNhapHang, @MaSanPham, @SoLuong,  @DonGia);

        commit;
    end try
    begin catch
        rollback;
        print error_message();
    end catch
end;

EXEC dbo.sp_NhapHang 
    'NH01A', 'K01A', 'NV01A', 'NCC01A', 
    'SP01A', 100, 50000;

select * from NhapHang nh
where nh.MaSanPham like 'SP01A';

--======================================================

--thu tuc thanh toan
create or alter procedure sp_ThanhToan
    @MaThanhToan char(10),
    @MaHoaDon char(10),
    @PhuongThuc nvarchar(50)
as
begin
    set nocount on;
    begin tran;

    begin try
        declare @SoTien decimal(12,2), 
                @MaKhachHang char(10);

        select 
            @SoTien = TongTien,
            @MaKhachHang = MaKhachHang
        from HoaDon
        where MaHoaDon = @MaHoaDon;

        insert into ThanhToan ( MaThanhToan, MaHoaDon, MaKhachHang, NgayThanhToan, PhuongThucThanhToan, SoTien )
        values ( @MaThanhToan, @MaHoaDon, @MaKhachHang,getdate(), @PhuongThuc,  @SoTien);

        commit;
    end try
    begin catch
        rollback;
        print error_message();
    end catch
end;

EXEC sp_ThanhToan
    'TT02A', 'HD01A', N'Tien mat';

select * from HoaDon
where MaHoaDon like 'HD01A';

select * from ThanhToan
where MaThanhToan like 'TT02A';


--==========================================================

--thu tuc thong ke doanh thu
create or alter procedure sp_DoanhThu
as
begin
	select cast(NgayLap as date) as Ngay,
		sum(TongTien) as DoanhThu
	from HoaDon
	group by cast(NgayLap as date)
end;

EXEC sp_DoanhThu


--==========================================================

--thu tuc top san pham
create or alter procedure sp_TopSanPham
as
begin
	select top 5 sp.TenSanPham,
		sum(ct.SoLuong) as TongBan
	from ChiTietHoaDon as ct
	join SanPham as sp on sp.MaSanPham = ct.MaSanPham
	group by sp.TenSanPham
	order by TongBan desc;
end;

exec sp_TopSanPham;

--==================================================================

--them nhan vien
create or alter procedure sp_ThemNhanVien
	@MaNhanVien char(10),
	@TenNhanVien nvarchar(10),
	@SoDienThoai varchar(15),
	@Email varchar(100),
	@ChucVu nvarchar(100),
	@NgaySinh datetime,
	@NgayVaoLam datetime,
	@Luong decimal(12,2)
as
begin
	set nocount on;
	begin tran;

	begin try
		if exists (
			select 1 from NhanVien
			where MaNhanVien = @MaNhanVien)
			throw 50001, N'Ma nhan vien da ton tai',1;
		insert into NhanVien
		values (@MaNhanVien, @TenNhanVien,@SoDienThoai,@Email,@ChucVu,@NgaySinh,@NgayVaoLam,@Luong);

		commit;
	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

exec sp_ThemNhanVien 
	'NV002', 
	'cuong', 
	'0922611334', 
	'cuong@gmail.com',
	'Quan Ly', 
	'2000-05-10', 
	'2024-01-01', 
	8000000;

select * from NhanVien
where MaNhanVien like 'NV005';

--====================================================================

--xoa nhan vien
create or alter procedure sp_XoaNhanVien
	@MaNhanVien char(10)
as
begin
	set nocount on;
	begin tran;
	
	begin try
		delete from NhanVien
		where MaNhanVien = @MaNhanVien

		if @@rowcount = 0
			throw 50004, N'khong tim thay nhan vien',1;

		commit;
	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

exec sp_XoaNhanVien 'NV005';

select * from NhanVien
where MaNhanVien like 'NV005';

--====================================================================

--them san pham
create or alter procedure sp_ThemSanPham
	@MaSanPham char(10),
	@TenSanPham nvarchar(150),
	@DonGia decimal(12,2),
	@MaDanhMuc char(10),
	@MaNCC char(10),
	@MaKho char(10),
	@SoLuong int
as
begin
	set nocount on;
	begin tran;

	begin try
		if exists (
			select 1 from SanPham
			where MaSanPham = @MaSanPham)
			throw 50001, N'San pahm da ton tai', 1;
		insert into SanPham
		values (@MaSanPham, @TenSanPham, @DonGia, @MaDanhMuc,@MaNCC,@MaKho,@SoLuong);

		commit;
	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

EXEC sp_ThemSanPham 'SP01',N'Iphone 15',25000000,'DM01A','NCC01A','K01A',50;


select * from SanPham
where MaSanPham like 'SP01';


--==============================================================================

--xoa san pham
create or alter proc sp_XoaSanPHam
	@MaSanPham char(10)
as
begin
	set nocount on;
	begin tran;

	begin try
		delete from SanPham
		where MaSanPham = @MaSanPham;
		
		if @@rowcount = 0
			throw 50005, N'Khong tim thay san pham', 1;

		commit;
	end try
	begin catch
		rollback;
		print error_message();
	end catch
end;

exec sp_XoaSanPHam 'SP01';

select * from SanPham
where MaSanPham like 'SP01';
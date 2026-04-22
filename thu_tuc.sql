use QuanLyCuaHang;
go

--tinh ton kho
create or alter function fn_TonKho (@MaSanPham char(10))
returns int
as
begin
	declare @Nhap int = 0, @Ban int = 0;
	select @Nhap = isnull(sum(SoLuong),0)
	from ChiTietNhapHang
	where MaSanPham = @MaSanPham

	select @Ban = isnull(sum(SoLuong),0)
	from ChiTietNhapHang
	where MaSanPham = @MaSanPham
	return (@Nhap - @Ban)
end;

--thu tuc ban hang
create or alter procedure sp_BanHang
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

--thu tuc ton kho
create or alter procedure sp_KiemTraTonKho
	@MaSanPham char(10)
as
begin
	select dbo.fn_TonKho(@MaSanPham) as SoLuongTon;
end

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

--thu tuc thong ke doanh thu
create or alter procedure sp_DoanhThu
as
begin
	select cast(NgayLap as date) as Ngay,
		sum(TongTien) as DoanhThu
	from HoaDon
	group by cast(NgayLap as date)
end;

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

--them nhan vien
create or alter procedure sp_ThemNhanVien
	@MaNhanVien char(10),
	@TenNhanVien char(10),
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
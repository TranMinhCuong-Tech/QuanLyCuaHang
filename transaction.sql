use QuanLyCuaHang;
go

--tao hoa don + chi tiet hoa don - thanh toan

begin try
	begin transaction;
	--tao hoa don
	insert into HoaDon(MaHoaDon, MaKhachHang, MaNhanVien, MaSanPham, NgayLap, SoLuong, DonGia, TongTien)
	values ('HD04C', 'KH01A', 'NV01A', 'SP02B', getdate(), 1000, 2000, 20000000);

	--them chi tiet hoa don
	insert into ChiTietHoaDon(MaHoaDon, MaSanPham, MaKhachHang, MaNhanVien, SoLuong, DonGia, MaThanhToan)
	values ('HD04C', 'SP02B', 'KH01A', 'NV01A', 1000, 2000, 'TT02C');

	--thanh toan
	insert into ThanhToan(MaThanhToan, MaHoaDon, MaKhachHang, NgayThanhToan, PhuongThucThanhToan, SoTien, TrangThaiThanhToan)
	values('TT02C', 'HD04C', 'KH01A', getdate(), 'tien mat', 20000000, 'Hoan Thanh');

	commit;
	print N'transaction thanh cong';
end try
begin catch
	rollback;
	print error_message();
end catch;

select * from ThanhToan where MaHoaDon like 'HD04C';

--=========================================================================

--cap nhat gia: san pham + hoa don
begin try
	begin transaction;
	update SanPham
	set DonGia = DonGia * 1.1
	where MaDanhMuc like 'DM01A';

	--cap nhat tong tien hoa don
	update HoaDon
	set TongTien = TongTien * 1.1
	where MaHoaDon in (
			select MaHoaDon
			from ChiTietHoaDon
			where MaSanPham in (
				select MaSanPham
				from SanPham
				where MaSanPham like 'DM01A'
			)
	);

	commit;
	print N'cap nhat gia thanh cong'
end try
begin catch
	rollback
	print error_message();
end catch;

--==========================================================================

--dang ky nhan vien: nhap thon tin nhan vien
begin try
	begin transaction;
	insert into NhanVien(MaNhanVien, TenNhanVien, SoDienThoai, Email, ChucVu, NgaySinh, NgayVaoLam, Luong)
	values ('NV022', 'cuong', '0925341542','c@mail.com', 'Thu ngan', '2002-09-24', getdate(), 6000000);

	commit;
end try
begin catch
	rollback;
	print error_message();
end catch;

select * from NhanVien where MaNhanVien like 'NV022';

--====================================================================

--kiem tra dieu kien nghiep vu
begin try
	begin transaction;
	declare @Ton int, @SoLuongYeuCau int = 1, @DonGia decimal(12,2);
	select @Ton = 
		(
		select SoLuongTonKho from SanPham
		where MaSanPham like 'SP17Q'
		);
	select @DonGia = 
		(
		select DonGia from SanPham
		where MaSanPham like 'SP17Q'
		);

		if @Ton < @SoLuongYeuCau
		begin
			throw 50030, N'Khong du ton kho',1;
		end;

		--thanh toan
		insert into ThanhToan
		values ('TT750', 'HD17Q', 'KH17Q', getdate(), 'Tien mat', @SoLuongYeuCau*@DonGia, 'Hoan thanh');

		--cap nhat so luong
		if exists (
			select 1  from ThanhToan
			where MaThanhToan = 'TT750' and TrangThaiThanhToan like 'Hoan Thanh'
		)
		begin
			update SanPham
			set SoLuongTonKho = SoLuongTonKho - @SoLuongYeuCau
			where MaSanPham like 'SP17Q'
		end;
		commit;
end try
begin catch
	rollback;
	print error_message();
end catch;

select * from ThanhToan where MaThanhToan like 'TT700';

--=======================================================================================

--thanh toan
begin try
	begin transaction;
	declare @dongia decimal(12,2), @soluongton int, @soluongmua int = 2;
	select @soluongton = 
		(
		select SoLuongTonKho from SanPham
		where MaSanPham like 'SP13M'
		);

	select @dongia = 
		(
		select DonGia from SanPham
		where MaSanPham like 'SP13M'
		);

		if @soluongton < @soluongmua
		begin
			throw 50030, N'Khong du ton kho',1;
		end;

	--tao hoa don
	insert into HoaDon(MaHoaDon, MaKhachHang, MaNhanVien, MaSanPham, NgayLap, SoLuong, DonGia, TongTien)
	values ('HD900', 'KH02B', 'NV02B', 'SP13M', getdate(), @soluongmua, @dongia,@soluongmua*@dongia);

	insert into ThanhToan
	values ('TT900', 'HD900', 'KH02B', getdate(), 'Tien mat',(@soluongmua*@dongia) , 'Hoan thanh');

		--cap nhat so luong
		if exists (
			select 1  from ThanhToan
			where MaThanhToan = 'TT900' and TrangThaiThanhToan like 'Hoan Thanh'
		)
		begin
			update SanPham
			set SoLuongTonKho = SoLuongTonKho - @soluongmua
			where MaSanPham like 'SP13M'
		end;
		commit;
end try
begin catch
	rollback;
	print error_message();
end catch;
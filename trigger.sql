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


--trigger rollback khi nhap hang bat thuong
create or alter trigger trg_NhapHang_Rollback
on ChiTietNhapHang
after insert
as
begin
	set nocount on;
	begin try
		if exists (
			select 1 from inserted
			where SoLuong > 5000
		)
		begin
			throw 50005, N'So luong nhap vuot han cho phep',1;
		end

		if exists(
			select 1 from inserted as i
			join SanPham as sp on i.MaSanPham = sp.MaSanPham
			where i.DonGiaNhapHang > sp.DonGia
		)
		begin
			throw 50006,N'Gia nhap khong duoc lon hon gia ban', 1;
		end
	end try
	begin catch
		rollback transaction;
		print N'Rollback do nhap hang bat thuong';
	end catch
end;


--trigger rollback khi thanh toan sai tien
create or alter trigger trg_ThanhToan_Rollback
on ThanhToan
after insert
as
begin
	set nocount on;
	begin try
		if exists (
			select 1
			from inserted as i
			join HoaDon as hd on i.MaHoaDon = hd.MaHoaDon
			where i.SoTien <> hd.TongTien
		)
		begin
			throw 50001, N'So tien thanh toan khong khop voi hoa don',1;
		end;
	end try
	begin catch
		rollback transaction;
		print N'Du lieu bi rollback do loi thanh toan';
	end catch
end;

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
		throw 5009, N'Email da ton tai trong he thong',1;
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
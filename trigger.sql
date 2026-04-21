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
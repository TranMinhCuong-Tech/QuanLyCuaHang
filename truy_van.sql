use QuanLyCuaHang;
go

--Doanh thu theo ngay
select hd.NgayLap, sum(hd.TongTien) as DoanhThu
from HoaDon as hd
group by hd.NgayLap
order by day(hd.NgayLap);

--top san pham ban chay
select top 5 sp.MaSanPham, sp.TenSanPham, 
    sum(cthd.SoLuong) as TongBan
from ChiTietHoaDon as cthd
join SanPham as sp on sp.MaSanPham = cthd.MaSanPham
group by sp.MaSanPham, sp.TenSanPham
order by TongBan desc;

--doanh thu theo tung khach hang
select kh.MaKhachHang, kh.TenKhachHang, 
		sum(hd.TongTien) as TongChiTieu
from KhachHang as kh
join HoaDon as hd on hd.MaKhachHang = kh.MaKhachHang
group by kh.MaKhachHang, kh.TenKhachHang
order by TongChiTieu asc;

--san pham chua tung ban
select * from SanPham as sp
where not exists(
	select 1 from ChiTietHoaDon cthd
	where cthd.MaSanPham = sp.MaSanPham
);

--tong tien hoa don
select hd.MaHoaDon, (
	select sum(ct.SoLuong * ct.DonGia)
	from ChiTietHoaDon as ct
	where ct.MaHoaDon = hd.MaHoaDon
	) as TongTien
from HoaDon as hd;

--phan loai khach hang
select kh.TenKhachHang,
	sum(hd.TongTien) as TongTien,
	case
		when sum(hd.TongTien) > 200000 then N'VIP'
		when sum(hd.TongTien) > 100000 then N'Than thiet'
		else N'Binh thuong'
	end as XepHangKhachHang
from KhachHang as kh
join HoaDon as hd on kh.MaKhachHang = hd.MaKhachHang
group by kh.TenKhachHang;

--nhan vien ban nhieu nhat
select top 1 nv.MaNhanVien, nv.TenNhanVien, 
	sum(hd.TongTien) as DoanhThu
from NhanVien as nv
join HoaDon as hd on nv.MaNhanVien = hd.MaNhanVien
group by nv.MaNhanVien, nv.TenNhanVien
order by DoanhThu desc;

--san pham nhap nhieu nhat
select sp.MaSanPham, sp.TenSanPham,
	sum(ctnh.SoLuong) as TongNhap
from ChiTietNhapHang as ctnh
join SanPham as sp on sp.MaSanPham = ctnh.MaSanPham
group by sp.MaSanPham, sp.TenSanPham
order by TongNhap desc;
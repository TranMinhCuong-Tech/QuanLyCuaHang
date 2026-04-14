CREATE DATABASE QuanLyCuaHang;
GO
USE QuanLyCuaHang;
GO

--tao bang

create table NhanVien (
	MaNhanVien char(10) Primary key,
	TenNhanVien nvarchar(100) not null,
	SoDienThoai varchar (15) unique,
	Email varchar(100) unique,
	ChucVu nvarchar(100),
	NgayVaoLam datetime,
	Luong decimal(12, 2) check (Luong >= 0)
);

create table KhachHang(
	MaKhachHang char(10) primary key,
	TenKhachHang nvarchar(100) not null,
	SoDienThoai varchar(15) unique,
	Email varchar(100) unique,
	DiaChi nvarchar(255),
	NgayDangKy datetime default getdate()
);



create table HoaDon(
	MaHoaDon char(10) primary key,
	MaKhachHang char(10) not null,
	MaNhanVien char(10) not null,
	NgayLap datetime default getdate(),
	TongTien decimal(12, 2) check(TongTien >= 0),
	foreign key (MaKhachHang) references KhachHang(MaKhachHang),
	foreign key (MaNhanVien) references NhanVien(MaNhanVien)
);

create table DanhMuc (
	MaDanhMuc char(10) primary key,
	TenDanhMuc nvarchar(100) not null
);

create table NhaCungCap (
	MaNhaCungCap char(10) primary key,
	TenNhaCungCap nvarchar(150) not null,
	SoDienThoai varchar(15),
	Email varchar(100) unique,
	DiaChi nvarchar(255)
);

create table Kho (
	MaKho char(10) primary key,
	TenKho nvarchar(150) not null,
	DiaChi nvarchar(255)
);


create table SanPham (
	MaSanPham char(10) primary key,
	TenSanPham nvarchar(150) not null,
	DonGia decimal(12,2) check (DonGia >= 0),
	MaDanhMuc char(10) not null,
	MaNhaCungCap char(10) not null,
	foreign key (MaDanhMuc) references DanhMuc(MaDanhMuc),
	foreign key (MaNhaCungCap) references NhaCungCap(MaNhaCungCap)
);

create table TonKho (
	MaKho char(10),
	MaSanPham char(10),
	SoLuongTon int check (SoLuongTon >= 0),
	primary key (MaKho, MaSanPham),
	foreign key (MaKho) references Kho(MaKho),
	foreign key (MaSanPham) references SanPham(MaSanPham)
);


create table ChiTietHoaDon(
	MaHoaDon char(10),
	MaSanPham char(10),
	SoLuong int check(SoLuong > 0),
	DonGia decimal (12, 2) check(DonGia >= 0),
	primary key (MaHoaDon, MaSanPham),
	foreign key (MaHoaDon) references HoaDon(MaHoaDon),
	foreign key (MaSanPham) references SanPham(MaSanPham)
);

create table NhapHang(
	MaNhapHang char(10) primary key,
	MaKho char(10) not null,
	NgayNhap datetime default getdate(),
	MaNhanVien char(10) not null,
	MaNhaCungCap char(10) not null,
	foreign key (MaKho) references Kho(MaKho),
	foreign key (MaNhanVien) references NhanVien (MaNhanVien),
	foreign key (MaNhaCungCap) references NhaCungCap (MaNhaCungCap)
);

create table ChiTietNhapHang (
	MaNhapHang char(10),
	MaSanPham char(10),
	SoLuong int check(SoLuong > 0),
	DonGiaNhapHang decimal(12, 2) check (DonGiaNhapHang >= 0),
	primary key (MaNhapHang, MaSanPham),
	foreign key (MaNhapHang) references NhapHang(MaNhapHang),
	foreign key (MaSanPham) references SanPham(MaSanPham)
);

create table ThanhToan (
	MaThanhToan char(10) primary key,
	MaHoaDon char(10) not null,
	NgayThanhToan datetime default getdate(),
	PhuongThucThanhToan nvarchar(50) not null,
	SoTien decimal(12,2) check (SoTien >= 0),
	foreign key (MaHoaDon) references HoaDon(MaHoaDon)
);

create table LichSuMuaHang (
	MaLichSu int identity primary key,
	MaKhachHang char(10) not null,
	MaHoaDon char(10) not null,
	NgayMua datetime default getdate(),
	foreign key (MakhachHang) references KhachHang(MaKhachHang),
	foreign key (MaHoaDon) references HoaDon(MaHoaDon)
);
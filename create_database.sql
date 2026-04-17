CREATE DATABASE QuanLyCuaHang;
GO
USE QuanLyCuaHang;
GO

CREATE TABLE NhanVien (
    MaNhanVien CHAR(10) PRIMARY KEY,
    TenNhanVien NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    ChucVu NVARCHAR(100),
    NgaySinh DATETIME,
    NgayVaoLam DATETIME,
    Luong DECIMAL(12,2) CHECK (Luong >= 0)
);

CREATE TABLE KhachHang (
    MaKhachHang CHAR(10) PRIMARY KEY,
    TenKhachHang NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(255)
);

CREATE TABLE DanhMuc (
    MaDanhMuc CHAR(10) PRIMARY KEY,
    TenDanhMuc NVARCHAR(100) NOT NULL,
    SoLuongTonKho INT DEFAULT 0,
    MaNhaCungCap CHAR(10)
);


CREATE TABLE NhaCungCap (
    MaNhaCungCap CHAR(10) PRIMARY KEY,
    TenNhaCungCap NVARCHAR(150) NOT NULL,
    SoDienThoai VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(255)
);

CREATE TABLE Kho (
    MaKho CHAR(10) PRIMARY KEY,
    TenKho NVARCHAR(150) NOT NULL,
    DiaChi NVARCHAR(255),
    MaSanPham CHAR(10),
    SoLuongTonKho INT CHECK (SoLuongTonKho >= 0)
);

CREATE TABLE SanPham (
    MaSanPham CHAR(10) PRIMARY KEY,
    TenSanPham NVARCHAR(150) NOT NULL,
    DonGia DECIMAL(12,2) CHECK (DonGia >= 0),
    MaDanhMuc CHAR(10) NOT NULL,
    MaNhaCungCap CHAR(10) NOT NULL,
    MaKho CHAR(10),
    SoLuongTonKho INT DEFAULT 0,

    FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc),
    FOREIGN KEY (MaNhaCungCap) REFERENCES NhaCungCap(MaNhaCungCap),
    FOREIGN KEY (MaKho) REFERENCES Kho(MaKho)
);

CREATE TABLE HoaDon (
    MaHoaDon CHAR(10) PRIMARY KEY,
    MaKhachHang CHAR(10),
    MaNhanVien CHAR(10),
    MaSanPham CHAR(10),
    NgayLap DATETIME NOT NULL,
    SoLuong INT CHECK (SoLuong > 0),
    DonGia DECIMAL(12,2),
    TongTien DECIMAL(12,2),

    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);

CREATE TABLE ChiTietHoaDon (
    MaHoaDon CHAR(10),
    MaSanPham CHAR(10),
    MaKhachHang CHAR(10),
    MaNhanVien CHAR(10),
    SoLuong INT CHECK (SoLuong > 0),
    DonGia DECIMAL(12,2),
    TongTien AS (SoLuong * DonGia) PERSISTED,
    MaThanhToan CHAR(10),
    DonGiaNhapHang DECIMAL(12,2),
    NgayNhapHang DATETIME,

    PRIMARY KEY (MaHoaDon, MaSanPham),

    FOREIGN KEY (MaHoaDon) REFERENCES HoaDon(MaHoaDon),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham),
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);

CREATE TABLE NhapHang (
    MaNhapHang CHAR(10) PRIMARY KEY,
    MaKho CHAR(10),
    MaNhanVien CHAR(10),
    MaNhaCungCap CHAR(10),
    MaSanPham CHAR(10),
    NgayNhap DATETIME,
    SoLuong INT CHECK (SoLuong >= 0),

    FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaNhaCungCap) REFERENCES NhaCungCap(MaNhaCungCap),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);

CREATE TABLE ChiTietNhapHang (
    MaNhapHang CHAR(10),
    MaSanPham CHAR(10),
    NgayNhapHang DATETIME,
    MaNhanVien CHAR(10),
    MaKho CHAR(10),
    DiaChiKho NVARCHAR(255),
    MaNhaCungCap CHAR(10),
    SoLuong INT CHECK (SoLuong > 0),
    DonGiaNhapHang DECIMAL(12,2),

    PRIMARY KEY (MaNhapHang, MaSanPham),

    FOREIGN KEY (MaNhapHang) REFERENCES NhapHang(MaNhapHang),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    FOREIGN KEY (MaNhaCungCap) REFERENCES NhaCungCap(MaNhaCungCap)
);

CREATE TABLE ThanhToan (
    MaThanhToan CHAR(10) PRIMARY KEY,
    MaHoaDon CHAR(10),
    MaKhachHang CHAR(10),
    NgayThanhToan DATETIME,
    PhuongThucThanhToan NVARCHAR(50),
    SoTien DECIMAL(12,2),

    FOREIGN KEY (MaHoaDon) REFERENCES HoaDon(MaHoaDon),
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);

# Hệ Quản Trị Cơ SỞ Dữ Liệu
Repos này sử dụng dữ liệu ảo để phục vụ cho môn hệ quan trị cơ sở dữ liệu.

Cách sử dụng repos

cách 1:
    clone repos về mày tính cá nhân:
    git clone https://github.com/TranMinhCuong-Tech/QuanLyCuaHang.git
    vào SSMS (SQL Server Management)
    click chuột phải chọn Databases --> Attach... --> Add... --> chọn file QuanLyCuaHang.mdf và file QuanLyCuaHang_log.ldf --> OK

cách 2: (nếu cách 1 không thực hiện đươc)
    clone repos về mày tính cá datasdatas
    thực hiện theo thứ tự sau:
        tạo database:
            New Query --> copy nội dung trong file create_database.sql --> dán vào New Query --> chọn toàn bộ nội dung --> nhấn phím F5 hoặc click chuột chọn Execute
        nạp data ảoảo:
            New Query --> copy nội dung trong file create_virtual_datas.sql --> dán vào New Query --> chọn toàn bộ nội dung --> nhấn phím F5 hoặc click chuột chọn Execute

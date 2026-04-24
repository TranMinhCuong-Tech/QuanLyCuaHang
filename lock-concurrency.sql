use QuanLyCuaHang;
go

--demo lock
--exclusive lock (x lock)
--sesson1
begin transaction;
update SanPham
set DonGia = DonGia * 1.1
where MaSanPham like 'SP01A';

waitfor delay '00:00:10';
commit;

--sesson2
select * from SanPham
where MaSanPham like 'SP01A';

/*
khi execute sesson1 truoc
sau do execute session2 sau khi execute sesspn1 truoc 10 giay
==> session2 bi bloked
*/

--share lock (S lock)
--session1
begin transaction;
select * from SanPham
where MaSanPham like 'SP01A';
waitfor delay '00:00:10';
commit;

--session2
update SanPham
set DonGia = 10000
where MaSanPham like 'SP01A';

/*
khi execute sesson1 truoc
sau do execute session2 sau khi execute sesspn1 truoc 10 giay
==> session2 bi bloked
*/

--lock timeout
--session1
update SanPham
set DonGia = 10000
where MaSanPham like 'SP01A';

--session2
set lock_timeout 5000;
update SanPham
set DonGia = 11000
where MaSanPham like 'SP01A';

/*
mot transaction dang giua lock
transaction khac muon dung du lieu do
nhung phai cho qua lau --> timeout
--> dung(stop) lenh
*/

select * from SanPham where MaSanPham like 'SP01A';




--demo concurrency 
--lost update
--session1
begin transaction;
select SoLuongTonKho from SanPham
where MaSanPham like 'SP01A';

waitfor delay '00:00:10'

update SanPham
set SoLuongTonKho = SoLuongTonKho - 1
where MaSanPham like 'SP01A';

commit;

--session2
begin transaction;
select SoLuongTonKho from SanPham
where MaSanPham like 'SP01A';

update SanPham
set SoLuongTonKho = SoLuongTonKho - 2
where MaSanPham like 'SP01A';

commit;

/*
ss1 thuc thi cap nhat gia cua san pham sp01a
ss2 truy cap vao san pham sp01a
ca 2 transaction cung tuy cap 1 du lieu
==> lost update
*/

--dirty read
--session1
begin transaction;
update SanPham
set DonGia = 10000
where MaSanPham like 'SP01A'
waitfor delay '00:00:15';
rollback;

--session2
set transaction isolation level read uncommitted;
select * from SanPham
where MaSanPham like 'SP01A';

/*
ss1 cap nhat gia san pham sp01a
ss2 doc du lieu chua commit tu san pham sp01a
--> dirty read
*/


--non-repeatable read
--session1
begin transaction;
select DonGia from SanPham
where MaSanPham like 'SP01A';

waitfor delay '00:00:15';

begin transaction;
select DonGia from SanPham
where MaSanPham like 'SP01A';

commit;

--session2
update SanPham
set DonGia = DonGia + 1000
where MaSanPham like 'SP01A';

/*
gia san pham se bi thay doi sau 2 lan select
*/

--deadlock
--session1
BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE SanPham
    SET DonGia = DonGia + 50
    WHERE MaSanPham = 'SP01A';

    WAITFOR DELAY '00:00:10';

    UPDATE SanPham
    SET DonGia = DonGia + 50
    WHERE MaSanPham = 'SP02B';

    COMMIT;

END TRY
BEGIN CATCH

    PRINT N'Deadlock xay ra - rollback';

    ROLLBACK;

END CATCH;

--session2
BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE SanPham
    SET DonGia = DonGia + 50
    WHERE MaSanPham = 'SP02A';

    WAITFOR DELAY '00:00:10';

    UPDATE SanPham
    SET DonGia = DonGia + 50
    WHERE MaSanPham = 'SP01A';

    COMMIT;

END TRY
BEGIN CATCH

    PRINT N'Deadlock xay ra - rollback';

    ROLLBACK;

END CATCH;
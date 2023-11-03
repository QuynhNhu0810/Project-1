--Em xài SQL Server nên function có hơi khác xíu ạaa. Dới cho em hỏi ngu một xíu là mỗi lần alter hay add column là mình phải type lại hàng ALTER TABLE luôn ạ?
use Project
create table SALES_DATASET_RFM_PRJ
(
  ordernumber VARCHAR(50),
  quantityordered VARCHAR(50),
  priceeach        VARCHAR(50),
  orderlinenumber  VARCHAR(50),
  sales            VARCHAR(50),
  orderdate        VARCHAR(50),
  status           VARCHAR(50),
  productline      VARCHAR(50),
  msrp             VARCHAR(50),
  productcode      VARCHAR(50),
  customername    VARCHAR(50),
  phone           VARCHAR(50),
  addressline1     VARCHAR(50),
  addressline2     VARCHAR(50),
  city             VARCHAR(50),
  state           VARCHAR(50),
  postalcode      VARCHAR(50),
  country          VARCHAR(50),
  territory        VARCHAR(50),
  contactfullname  VARCHAR(50),
  dealsize         VARCHAR(50)
) 
--CHANGE DATA TYPE--
select *
from dbo.SALES_DATASET_RFM_PRJ

alter table dbo.SALES_DATASET_RFM_PRJ
alter column ordernumber int

alter table dbo.SALES_DATASET_RFM_PRJ
alter column quantityordered int

alter table dbo.SALES_DATASET_RFM_PRJ
alter column priceeach numeric

alter table dbo.SALES_DATASET_RFM_PRJ
alter column orderlinenumber int

alter table dbo.SALES_DATASET_RFM_PRJ
alter column sales numeric

alter table dbo.SALES_DATASET_RFM_PRJ
alter column orderdate datetime

alter table dbo.SALES_DATASET_RFM_PRJ
alter column msrp int

--CHECK FOR NULL OR BLANK--
delete from dbo.SALES_DATASET_RFM_PRJ
where quantityordered is null or quantityordered = '' ''

delete from dbo.SALES_DATASET_RFM_PRJ
where ordernumber is null or ordernumber = '' ''

delete from dbo.SALES_DATASET_RFM_PRJ
where priceeach is null or priceeach = '' ''

delete from dbo.SALES_DATASET_RFM_PRJ
where orderlinenumber is null or orderlinenumber = '' ''

delete from dbo.SALES_DATASET_RFM_PRJ
where sales is null or sales = '' ''

delete from dbo.SALES_DATASET_RFM_PRJ
where orderdate is null or orderdate = '' ''

--ADD AND FORMAT Last Name and First Name
alter table dbo.SALES_DATASET_RFM_PRJ
add contactlastname varchar(200)

alter table dbo.SALES_DATASET_RFM_PRJ
add contactfirstname varchar(200)

update dbo.SALES_DATASET_RFM_PRJ
set contactlastname = substring(contactfullname,1,charindex('-',contactfullname) - 1)

update dbo.SALES_DATASET_RFM_PRJ
set contactfirstname = substring(contactfullname,charindex('-',contactfullname) + 1, len(contactfullname)-charindex('-',contactfullname))

update dbo.SALES_DATASET_RFM_PRJ
set contactlastname = upper(left(contactlastname,1)) + lower(right(contactlastname,len(contactlastname)-1))

update dbo.SALES_DATASET_RFM_PRJ
set contactfirstname = upper(left(contactfirstname,1)) + lower(right(contactfirstname,len(contactfirstname)-1))

--ADD YEAR/MONTH/QUARTER--
alter table dbo.SALES_DATASET_RFM_PRJ
add qtr_id int, month_id int, year_id int

update dbo.SALES_DATASET_RFM_PRJ
set qtr_id = datepart(quarter,orderdate)

update dbo.SALES_DATASET_RFM_PRJ
set month_id = datepart(month,orderdate)

update dbo.SALES_DATASET_RFM_PRJ
set year_id = datepart(year,orderdate)

--FIND OUTLIER--
with cte as 
(
select quantityordered
,(select avg(quantityordered) from dbo.SALES_DATASET_RFM_PRJ) as avg
,(select stddev(quantityordered) from dbo.SALES_DATASET_RFM_PRJ) as stddev
from dbo.SALES_DATASET_RFM_PRJ)

,outlier as(
select quantityordered, (quantityordered-avg)/stddev as z_score
from cte
where abs(quantityordered-avg)/stddev) >3)

update dbo.SALES_DATASET_RFM_PRJ
set quantityordered = (select avg(quantityordered)
from dbo.SALES_DATASET_RFM_PRJ)
where quantityordered in (select quantityordered from outlier)

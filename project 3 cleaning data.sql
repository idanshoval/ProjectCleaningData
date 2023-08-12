--Cleaning Data

-- alter column date type 
alter table NashvillHousing
alter column saledate date
-------------------------------------------------------------------------------------------------------------------------
--Replace where PropertyAddress is Null
update n1
set n1.PropertyAddress= n.PropertyAddress
from NashvillHousing n inner join NashvillHousing n1 on n.ParcelID=n1.ParcelID and n1.[UniqueID ]<>n.[UniqueID ]
 where n1.PropertyAddress is null and n.PropertyAddress is not null
 ----------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address,City, State)
select SUBSTRING(n.PropertyAddress,1,CHARINDEX(',',n.PropertyAddress)-1) as address,SUBSTRING(n.PropertyAddress,CHARINDEX(',',n.PropertyAddress)+1,len(n.PropertyAddress)) as address
from NashvillHousing n

alter table NashvillHousing
add PropretySplitAddr nvarchar(100)

alter table NashvillHousing
add PropretySplitCity nvarchar(100)
--Update the new data

update NashvillHousing
set PropertyAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1), PropretySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 
 
 
 --- The same with OwnerAddress
 select PARSENAME(REPLACE(n.OwnerAddress,',','.'),3),PARSENAME(REPLACE(n.OwnerAddress,',','.'),2),PARSENAME(REPLACE(n.OwnerAddress,',','.'),1)
 from NashvillHousing n 
 
 --Add columns
 alter table NashvillHousing
 add owner_addr nvarchar(100),ownercity nvarchar(100) ,state_ nvarchar(100)


 update NashvillHousing
 set NashvillHousing.owner_addr=PARSENAME(REPLACE(OwnerAddress,',','.'),3),ownercity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),state_=PARSENAME(REPLACE(OwnerAddress,',','.'),1)



select *  
from NashvillHousing
 

-- Drop unnecessary columns
alter table NashvillHousing
drop column PropretySplitAddr

alter table NashvillHousing
drop column OwnerAddress


----------------------------------------------------------------------------------------------------------------------------------------------
--- Change format Y or N  to Yes or No
update NashvillHousing
set SoldAsVacant=  case when SoldAsVacant='N' then 'No' 
when SoldAsVacant='Y'then 'Yes'
ELSE SoldAsVacant
end 
-------------------------------------------------------------------------------------------------------------------------------------------------
--delete duplicate rows
with cte_ as (
select *,row_number() over (partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by [UniqueID ]) as row_number_
from NashvillHousing
)

delete
from cte_
where row_number_>1
----------------------------------------------------------------------------------------------------------------------------------------------

-- Drop unnecessary columns
alter table NashvillHousing
drop column taxdistrict
-------------------------------------------------------------------------------------------------------------------------------------------------
-- More queries:

Create table Employees
(
 ID int primary key identity,
 FirstName nvarchar(50),
 LastName nvarchar(50),
 Gender nvarchar(50),
 Salary int
)


Insert into Employees values ('Ben', 'Hoskins', 'Male', 70000)
Insert into Employees values ('Mark', 'Hastings', 'Male', 60000)
Insert into Employees values ('Steve', 'Pound', 'Male', 45000)
Insert into Employees values ('Ben', 'Hoskins', 'Male', 70000)
Insert into Employees values ('Philip', 'Hastings', 'Male', 45000)
Insert into Employees values ('Mary', 'Lambeth', 'Female', 30000)
Insert into Employees values ('Valarie', 'Vikings', 'Female', 35000)
Insert into Employees values ('John', 'Stanmore', 'Male', 80000)


--------------------------------------------------------------------
--Q1)Find the N^th Highest Salary 

declare @N int
SET @N= 6
select Top 1 Result.Salary
from (select  distinct TOP (@N) Salary
      from Employees
       order by salary desc) as  Result
order by Salary 

--Option 2
with cte_table as(
select salary,DENSE_RANK() over (order by Salary desc) as rank_
from Employees 
)

select Salary
from cte_table
where rank_=2
---------------------------------------------------------------------------------------------------------------------------------
drop table Employees
Create table Employees
(
 EmployeeID int primary key identity,
 EmployeeName nvarchar(50),
 ManagerID int foreign key references Employees(EmployeeID)
)
GO

Insert into Employees values ('John', NULL)
Insert into Employees values ('Mark', NULL)
Insert into Employees values ('Steve', NULL)
Insert into Employees values ('Tom', NULL)
Insert into Employees values ('Lara', NULL)
Insert into Employees values ('Simon', NULL)
Insert into Employees values ('David', NULL)
Insert into Employees values ('Ben', NULL)
Insert into Employees values ('Stacy', NULL)
Insert into Employees values ('Sam', NULL)
GO

Update Employees Set ManagerID = 8 Where EmployeeName IN ('Mark', 'Steve', 'Lara')
Update Employees Set ManagerID = 2 Where EmployeeName IN ('Stacy', 'Simon')
Update Employees Set ManagerID = 3 Where EmployeeName IN ('Tom')
Update Employees Set ManagerID = 5 Where EmployeeName IN ('John', 'Sam')
Update Employees Set ManagerID = 4 Where EmployeeName IN ('David')
GO



--Q2)If an EmployeeId is passed, the query should list down the entire organization hierarchy i.e who is the manager of the EmployeeId passed and who is managers manager and so on till full hierarchy is listed.

--Solution Recursive
declare @id int ;
set @id=7;

with Cte_Empoyees as 
(
select e.EmployeeID,e.EmployeeName,e.ManagerID
from Employees e
where e.EmployeeID=@id

Union all
select e.EmployeeID,e.EmployeeName,e.ManagerID
from Employees e inner join Cte_Empoyees c on e.EmployeeID=c.ManagerID
)
select c1.EmployeeName,c2.EmployeeName as Manager
from Cte_Empoyees c1  left outer join Cte_Empoyees c2 on c1.ManagerID=c2.EmployeeID

------------------------------------------------------------------------------------
drop  table if exists Employees
Create table Employees
(
 ID int,
 FirstName nvarchar(50),
 LastName nvarchar(50),
 Gender nvarchar(50),
 Salary int
)
GO

Insert into Employees values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees values (2, 'Mary', 'Lambeth', 'Female', 30000)
Insert into Employees values (2, 'Mary', 'Lambeth', 'Female', 30000)
Insert into Employees values (3, 'Ben', 'Hoskins', 'Male', 70000)
Insert into Employees values (3, 'Ben', 'Hoskins', 'Male', 70000)
Insert into Employees values (3, 'Ben', 'Hoskins', 'Male', 70000)
--Q3) deleting all duplicate rows except one from a sql server table


 with cte as 
 (
 select  Employees.ID, ROW_NUMBER() over(partition by id order by id ) as row_number_
  from Employees
  )
delete
 from cte
 where  row_number_>1
select * from DataCleaninProject..Sheet1;

select SaleDate from DataCleaninProject..Sheet1;

--Changing into date format

select convert(Date,SaleDate) as SalesDateConverted
from DataCleaninProject..Sheet1;

update DataCleaninProject..Sheet1
set SaleDate=convert(date,SaleDate)


--Filling up the missing property address

--checking the missing values
select * from DataCleaninProject..Sheet1 
where PropertyAddress is null 
order by ParcelID;

--getting the values from duplicate
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from DataCleaninProject..Sheet1 a
Join DataCleaninProject..Sheet1 b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--filling the missing values
update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from DataCleaninProject..Sheet1 a
Join DataCleaninProject..Sheet1 b
on a.ParcelID=b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking address into several individual columns

--For property address

select PropertyAddress
from DataCleaninProject..Sheet1;

select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from DataCleaninProject..Sheet1

--Update the values in database

alter table DataCleaninProject..Sheet1
add PropertySplitAddress nvarchar(200)

update DataCleaninProject..Sheet1
set PropertySplitAddress= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


alter table DataCleaninProject..Sheet1
add PropertySplitCity nvarchar(200)


update DataCleaninProject..Sheet1
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from DataCleaninProject..Sheet1;

--for owner address

select OwnerAddress
from DataCleaninProject..Sheet1

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as city
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as county
From DataCleaninProject..Sheet1

alter table DataCleaninProject..Sheet1
add SplitOwnerCity nvarchar(220)

update DataCleaninProject..Sheet1
set SplitOwnerCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 


alter table DataCleaninProject..Sheet1
add SplitOwnerAddress nvarchar(220)

update DataCleaninProject..Sheet1
set SplitOwnerAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


alter table DataCleaninProject..Sheet1
add SplitOwnerState nvarchar(220)

update DataCleaninProject..Sheet1
set SplitOwnerState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 


select * from DataCleaninProject..Sheet1


--Renaming Y as yes and N as No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaninProject.dbo.Sheet1
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From DataCleaninProject.dbo.Sheet1


Update DataCleaninProject..Sheet1
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Removing the Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From DataCleaninProject.dbo.Sheet1
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From DataCleaninProject.dbo.Sheet1


-- Deleting the Unused Columns


ALTER TABLE DataCleaninProject.dbo.Sheet1
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



Select *
From DataCleaninProject.dbo.Sheet1
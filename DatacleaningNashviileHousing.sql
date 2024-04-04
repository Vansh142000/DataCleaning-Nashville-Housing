  select *
  from NashvilleHousingg  
  
  
-- Standardize Date Format
Alter table  NashvilleHousingg
add salesDateConverted Date;

update NashvilleHousingg
set salesDateConverted= CONVERT(Date,SaleDate)


-- Populate Property Address data
select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingg a 
join NashvilleHousingg b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a 
set propertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingg a 
join NashvilleHousingg b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out PropertyAddress into Individual Columns i.e Address, City
Select PropertyAddress
From NashvilleHousingg

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousingg

alter table NashvilleHousingg
add PropertySplitAddress Nvarchar(255)

update NashvilleHousingg
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

alter table NashvilleHousingg
add PropertySplitCity Nvarchar(255)

update NashvilleHousingg
set PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 

---- Now Breaking out OwnerAddress into Individual Columns i.e Address, City, State
select OwnerAddress
from NashvilleHousingg

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousingg

alter table NashvilleHousingg
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingg
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousingg
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingg
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousingg
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingg
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(soldasvacant) , count(soldasvacant)
from NashvilleHousingg
group by SoldAsVacant

select SoldAsVacant ,
	case when soldasvacant = 'Y' then 'Yes'
	     when soldasvacant = 'N' then 'No'
		 else soldasvacant
	end
from NashvilleHousingg

update NashvilleHousingg
set SoldAsVacant=case when soldasvacant = 'Y' then 'Yes'
	     when soldasvacant = 'N' then 'No'
		 else soldasvacant
	end

-- Remove Duplicates
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

From NashvilleHousingg
)
Delete 
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns
Select *
From NashvilleHousingg

alter table  NashvilleHousingg
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate







		

/*

Cleaning Data in SQL Queries

*/

select * from 
PortfolioProject..NashvilleHousing


-- Standardize Date Format


alter table NashvilleHousing
alter column SaleDate Date


-- Populate Property Address data

select * from 
PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  from 
PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from 
PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING ( PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) - 1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING ( PropertyAddress, CHARINDEX( ',' , PropertyAddress) + 1, LEN(PropertyAddress))


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',' , '.'),3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',' , '.'),2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',' , '.'),1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant)
from 
PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


-- Remove Duplicates

with RowNumCTE as (
select *, 
    ROW_NUMBER() over(
    partition by ParcelID, 
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID  
)
delete from RowNumCTE 
where row_num > 1
--order by PropertyAddress


-- Delete Unused Columns

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
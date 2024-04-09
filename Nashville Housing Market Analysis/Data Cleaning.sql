--Cleaning data in SQL for Nashville Housing Market Analysis


select * from portfolioproject.dbo.NashvilleHousing 



--"standardize date format"
select SaleDate from portfolioproject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, saledate)

--as update doesn't updated saledate format to date, we will use alter

select SaleDate from NashvilleHousing;
--so now we will add one column, and in that column we will update our column

alter table NashvilleHousing 
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, saledate)

select saledateconverted from NashvilleHousing;

--"Populate Property Address data"
--fill the null values of address
select * from NashvilleHousing 
where PropertyAddress is null ;
--showing null values
select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID  <>b.UniqueID
  where a.PropertyAddress is null

 update a
 set PropertyAddress =  isnull (a.PropertyAddress,b.PropertyAddress)
 from NashvilleHousing a
join NashvilleHousing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID  <>b.UniqueID
  where a.PropertyAddress is null

--Breaking out Address Into Individual Columns (address, city, state)


select PropertyAddress from NashvilleHousing 

select 
substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))
from NashvilleHousing 

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress));

--spliting the address with parsename
select owneraddress from NashvilleHousing;

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

select * from NashvilleHousing;

--change y and n, to yes and no in 'sold as vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

update NashvilleHousing
SET SoldAsVacant =
Case
when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END


select * from NashvilleHousing

--Remove Duplicates(first we partition bases on several columns and then given them order, and delete)



With RowNumCTE AS (
select *,
ROW_NUMBER() Over (PARTITION  BY
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by 
	uniqueid
	) as row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num >1


select * from NashvilleHousing

--Delete Unused Columns 
alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict 

--FINAL OUTPUT AFTER DATA CLEANING

select * from NashvilleHousing


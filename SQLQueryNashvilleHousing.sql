SELECT *
FROM PortolioProject.dbo.NashvilleHousing


--Cleaning Data in SQL Queries

--1) Standardize Date Format --------------------------------------------------------------------------------------------------------

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM PortolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 


--2)Fix NULL Property Address Data --------------------------------------------------------------------------------------------------------

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortolioProject.dbo.NashvilleHousing a
JOIN PortolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortolioProject.dbo.NashvilleHousing a
JOIN PortolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null


--3) Split Adress intp Address, City & State Columns -------------------------------------------------------------------------------------------------------- 

SELECT SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT* 
FROM PortolioProject.dbo.NashvilleHousing 

--4) Spilt OwnerAddress -------------------------------------------------------------------------------------------------------- 

SELECT PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
FROM PortolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OnwerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OnwerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OnwerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OnwerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OnwerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OnwerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)


SELECT*
From PortolioProject.dbo.NashvilleHousing




--5) Convert Y to YES and N to NO in "Sold as Vacant" field --------------------------------------------------------------------------------------------------------

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
From PortolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2                               -- Checking different types of Values


SELECT SoldAsVacant,                                   --Formating 
	CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
	WHEN SoldAsVacant= 'N' THEN 'NO'
	ELSE SoldAsVacant END
From PortolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET  SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'YES'
	WHEN SoldAsVacant= 'N' THEN 'NO'
	ELSE SoldAsVacant END
From PortolioProject.dbo.NashvilleHousing



--6) Duplicates -------------------------------------------------------------------------------------------------------- 

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,SalePrice,SaleDate,PropertyAddress, LegalReference
		ORDER BY UniqueID) row_num
From PortolioProject.dbo.NashvilleHousing
)
SELECT*        --(DELETE)
FROM RowNumCTE
WHERE row_num = 1
ORDER BY SaleDate


--7) Delete Unwanted Columns -------------------------------------------------------------------------------------------------------- 

SELECT *
From PortolioProject.dbo.NashvilleHousing
ORDER BY SalePrice


ALTER TABLE PortolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PopertySplitAddress, PropertyAddress, SaleDate


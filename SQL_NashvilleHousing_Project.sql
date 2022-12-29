SELECT *
FROM nashvillehousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(Date, SaleDate)          -- does not work

ALTER TABLE nashvillehousing
Add SaleDate2 Date;

UPDATE nashvillehousing
SET SaleDate2 = CONVERT(Date, SaleDate)

-- Populate Property Address Data

SELECT *
FROM nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT *
FROM nashvillehousing

-- Breaking Out Address Into Individual Columns

SELECT PropertyAddress
FROM nashvillehousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) as Street
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add PropertyStreet nvarchar(255);

UPDATE nashvillehousing
SET PropertyStreet = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE nashvillehousing
Add PropertyCity nvarchar(255);

UPDATE nashvillehousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM nashvillehousing

SELECT OwnerAddress
FROM nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add OwnerStreet nvarchar(255);

UPDATE nashvillehousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
Add OwnerCity nvarchar(255);

UPDATE nashvillehousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvillehousing
Add OwnerState nvarchar(255);

UPDATE nashvillehousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM nashvillehousing

-- Change Y and N to Yes and No in "Sold As Vacant" Field

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Delete Unused Columns

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate
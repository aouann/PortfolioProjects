--CLEANING NASHVILLE HOUSING DATA

--SELECTING THE ENTIRE TABLE
SELECT *
FROM PortfolioProject..NashvilleHousing


--CHANGE DATE FORMAT
--only include date and exclude time
ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate DATE


--POPULATE PROPERTY ADDRESS DATA
--Fill empty PropertyAddress data with PropertyAddress from other entry with the same ParcelID
SELECT a.[UniqueID ]UniqueID_A, a.PropertyAddress PropAddress_A, a.ParcelID ParcelID_A, b.ParcelID ParcelID_B, b.[UniqueID ] UniqueID_B, b.PropertyAddress PropAddress_B, ISNULL(a.PropertyAddress, b.PropertyAddress) AS AddressToBeUsed
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--BREAK DOWN PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS
SELECT  PropertyAddress,
LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) AS Address,
RIGHT(PropertyAddress, LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropAddr_Address nvarchar(255),
PropAddr_City nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropAddr_Address = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1),
PropAddr_City = RIGHT(PropertyAddress, LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress))

SELECT PropertyAddress, PropAddr_Address, PropAddr_City
FROM  PortfolioProject..NashvilleHousing


--BREAK DOWN OWNER ADDRESS INTO INDIVIDUAL COLUMN
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddr_Address NVARCHAR(255),
OwnerAddr_City NVARCHAR(255),
OwnerAddr_State NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerAddr_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerAddr_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerAddr_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerAddr_Address, OwnerAddr_City, OwnerAddr_State
FROM PortfolioProject..NashvilleHousing



-- CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN SoldAsVacant COLUMN
SELECT SoldAsVacant ,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END AS SoldCondition
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing


-- IDENTIFY DUPLICATES

WITH RowNumber AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
ORDER BY UniqueID
) AS row_num

FROM PortfolioProject..NashvilleHousing
)

SELECT UniqueID,row_num
FROM RowNumber
WHERE row_num > 1

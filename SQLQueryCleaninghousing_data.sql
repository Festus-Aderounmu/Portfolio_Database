
/*

Cleaning data in SQL queries 

*/
SELECT * FROM housing_data

-- Standardize date format

SELECT SaleDate, CAST(SaleDate as date) 
FROM housing_data

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM housing_data

UPDATE housing_data
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE housing_data
ADD SaleDateConverted Date;

UPDATE housing_data
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted, CONVERT(DATE,SALEDATE) FROM housing_data

-- Populate Property Address Data

SELECT * FROM housing_data 
-- WHERE PropertyAddress IS NOT NULL 
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM housing_data A
JOIN housing_data B 
ON A.ParcelID = B.ParcelID 
AND A.UniqueID <> B.UniqueID 
WHERE A.PropertyAddress IS NULL 

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM housing_data A
JOIN housing_data B 
ON A.ParcelID = B.ParcelID 
AND A.UniqueID <> B.UniqueID 
WHERE A.PropertyAddress IS NULL 

SELECT PropertyAddress FROM housing_data
WHERE PropertyAddress IS NULL

-- Breaking out address into individual columns PropertyAddress(address, city, state)
--- SELECT PropertyAddress FROM housing_data WHERE PropertyAddress IS NOT NULL ORDER BY PropertyAddress DESC

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM housing_data

ALTER TABLE housing_data
ADD PropertySpiltAddress nvarchar(255); 

UPDATE housing_data
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE housing_data
ADD PropertySpiltCity nvarchar(255); 

UPDATE housing_data
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * FROM housing_data


-- Breaking out address into individual columns OwnerAddress(address, city, state)

SELECT OwnerAddress FROM housing_data

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM housing_data

ALTER TABLE housing_data
ADD OwnerSpiltAddress nvarchar(255); 

UPDATE housing_data
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing_data
ADD OwnerSpiltCity nvarchar(255); 

UPDATE housing_data
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing_data
ADD OwnerSpiltState nvarchar(255); 

UPDATE housing_data
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * FROM housing_data

-- Change Y and N to Yes and NO In 'SoldAsVacant'  field


SELECT DISTINCT(SoldASVacant), COUNT(SoldASVacant) FROM housing_data GROUP BY SoldASVacant ORDER BY SoldASVacant

SELECT SoldASVacant CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
WHEN SoldASVacant = 'N' THEN 'No'
ELSE SoldASVacant END 
FROM housing_data

UPDATE housing_data
SET SoldAsVacant = CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
WHEN SoldASVacant = 'N' THEN 'No'
ELSE SoldASVacant END

SELECT SoldASVacant FROM housing_data 
WHERE SoldAsVacant = 'No' OR SoldAsVacant = 'Yes'

SELECT SoldASVacant FROM housing_data 
WHERE SoldAsVacant LIKE '%Yes%' OR SoldAsVacant LIKE '%No%'

-- Remove Duplicates 
 
 WITH RowNumCte AS (

 SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
 ORDER BY UniqueID) row_num 
 FROM housing_data 
 -- ORDER BY ParcelID
 )
SELECT * FROM RowNumCte
WHERE row_num > 1 ORDER BY PropertyAddress

 WITH RowNumCte AS (

 SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
 ORDER BY UniqueID) row_num 
 FROM housing_data 
 -- ORDER BY ParcelID
 )
DELETE 
FROM RowNumCte
WHERE row_num > 1 
-- ORDER BY PropertyAddress

 WITH RowNumCte AS (

 SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
 ORDER BY UniqueID) row_num 
 FROM housing_data 
 -- ORDER BY ParcelID
 )
SELECT * FROM RowNumCte
WHERE row_num = 1 ORDER BY PropertyAddress

-- Delete Unused colums

SELECT * FROM housing_data

ALTER TABLE housing_data 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE housing_data 
DROP COLUMN SaleDate


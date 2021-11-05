--CLEANING DATA WITH SQL QUERIES

SELECT *
FROM [Portfolio Projects]..[Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE TIMESTAMP FROM DATE COLUMN

ALTER TABLE[Portfolio Projects].[dbo].[Nashville Housing]
ADD SalesDate Date;

UPDATE [Portfolio Projects].[dbo].[Nashville Housing]
SET SalesDate = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------------------------------

--FILL NULL VALUES IN PROPERTYADDRESS COLUMN


SELECT PropertyAddress, ParcelID
FROM [Portfolio Projects]..[Nashville Housing]
where PropertyAddress is null

--Since identical ParcelIDs have the same PropertyAdress, we populate the null values in PropertyAddress with the PropertyAddress 
--that matches the ParcelID for the null values in PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects]..[Nashville Housing] a
JOIN [Portfolio Projects]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects]..[Nashville Housing] a
JOIN [Portfolio Projects]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------------------------

--SPLITTING ADDRESS COLUMNs INTO ADDRESS, CITY AND STATE

--Splitting PropertyAddress using Substrings
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

FROM [Portfolio Projects]..[Nashville Housing]

--Update the table with these split columns
--Update Address
ALTER TABLE [Portfolio Projects]..[Nashville Housing]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Portfolio Projects]..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


--Update City
ALTER TABLE [Portfolio Projects]..[Nashville Housing]
ADD PropertySplitCity nvarchar(255)

UPDATE [Portfolio Projects]..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--SplittingOwnerAddress Using Parsename

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1) AS State

FROM [Portfolio Projects].[dbo].[Nashville Housing]

--Updating Table with these split columns
--Updating Address

ALTER TABLE [Portfolio Projects]..[Nashville Housing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Portfolio Projects]..[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 3)

--Updating City
ALTER TABLE [Portfolio Projects]..[Nashville Housing]
ADD OwnerSplitCity nvarchar(255);

UPDATE [Portfolio Projects]..[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 2)


--Updating State
ALTER TABLE [Portfolio Projects]..[Nashville Housing]
ADD OwnerSplitState nvarchar(255);

UPDATE [Portfolio Projects]..[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'), 1)


--------------------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y TO YES AND N TO NO IN SOLDASVACANT FIELD

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS CountSold
FROM [Portfolio Projects]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY CountSold 


SELECT SoldAsVacant,
CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Projects]..[Nashville Housing]

UPDATE [Portfolio Projects]..[Nashville Housing]
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS
SELECT * 
FROM [Portfolio Projects].[dbo].[Nashville Housing]


ALTER TABLE [Portfolio Projects].[dbo].[Nashville Housing]
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate
 

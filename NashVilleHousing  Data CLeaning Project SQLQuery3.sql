SELECT *
FROM PortfolioProject.dbo.NashvilleDataCleaning$

-- Standardize Date Format

SELECT SaledateConverted, CONVERT(Date,SaleDate) as SaleDate
FROM PortfolioProject.dbo.NashvilleDataCleaning$

UPDATE NashvilleDataCleaning$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleDataCleaning$
ADD SaledateConverted Date;

UPDATE NashvilleDataCleaning$
SET SaledateConverted = CONVERT(date,SaleDate)

-- Population Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleDataCleaning$
--WHERE PropertyAddress is null
ORDER by ParcelID

--NULL PropertyAddress Populated

SELECT a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleDataCleaning$ a
JOIN PortfolioProject.dbo.NashvilleDataCleaning$ b
    on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleDataCleaning$ a
JOIN PortfolioProject.dbo.NashvilleDataCleaning$ b
    on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Sorting Addresss into invalid colomns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.DBO.NashvilleDataCleaning$
--WHERE PropertyAddress is null
--ORDER BY  ParcelID]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleDataCleaning$


ALTER TABLE NashvilleDataCleaning$
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleDataCleaning$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleDataCleaning$
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleDataCleaning$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleDataCleaning$


--Sorting Owners Address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleDataCleaning$

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject.dbo.NashvilleDataCleaning$

ALTER TABLE NashvilleDataCleaning$
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleDataCleaning$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleDataCleaning$
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleDataCleaning$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleDataCleaning$
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleDataCleaning$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



--Change Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleDataCleaning$
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsvacant = 'Y' THEN 'Yes'
     WHEN SoldAsvacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	 FROM PortfolioProject.dbo.NashvilleDataCleaning$


UPDATE NashvilleDataCleaning$
SET SoldAsVacant = CASE WHEN SoldAsvacant = 'Y' THEN 'Yes'
         WHEN SoldAsvacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END


--Removing the dupklicates in the NashVille Housing Dataset


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                PropertyAddress,
								SalePrice,
								SaleDate,
								Legalreference
								ORDER BY UniqueID
								)
								row_num
FROM PortfolioProject.dbo.NashvilleDataCleaning$
--ORDER BY parcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                PropertyAddress,
								SalePrice,
								SaleDate,
								Legalreference
								ORDER BY UniqueID
								)
								row_num
FROM PortfolioProject.dbo.NashvilleDataCleaning$
--ORDER BY parcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleDataCleaning$
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleDataCleaning$
DROP COLUMN  SaleDate

SELECT *
FROM PortfolioProject.dbo.NashvilleDataCleaning$
/*
Cleaning Data in SQL Queries
*/

-- Select all columns from Method56dbaPortfolio
Select *
From Method56dbaPortfolio.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date, SaleDate)
From Method56dbaPortfolio.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If it doesn't Update properly
ALTER TABLE Method56dbaPortfolio.NashvilleHousing
Add SaleDateConverted Date;

Update Method56dbaPortfolio.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Method56dbaPortfolio.NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Method56dbaPortfolio.NashvilleHousing a
JOIN Method56dbaPortfolio.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Method56dbaPortfolio.NashvilleHousing a
JOIN Method56dbaPortfolio.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Method56dbaPortfolio.NashvilleHousing
-- Where PropertyAddress is null
-- order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From Method56dbaPortfolio.NashvilleHousing

ALTER TABLE Method56dbaPortfolio.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Method56dbaPortfolio.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Method56dbaPortfolio.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Method56dbaPortfolio.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From Method56dbaPortfolio.NashvilleHousing

Select OwnerAddress
From Method56dbaPortfolio.NashvilleHousing

Select
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerSplitState
From Method56dbaPortfolio.NashvilleHousing

Select *
From Method56dbaPortfolio.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Method56dbaPortfolio.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
    CASE
        When SoldAsVacant = 'Y' THEN 'Yes'
        When SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END as UpdatedSoldAsVacant
From Method56dbaPortfolio.NashvilleHousing

Update Method56dbaPortfolio.NashvilleHousing
SET SoldAsVacant =
    CASE
        When SoldAsVacant = 'Y' THEN 'Yes'
        When SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
    Select *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
            ORDER BY UniqueID
        ) as row_num
    From Method56dbaPortfolio.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Method56dbaPortfolio.NashvilleHousing

------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Method56dbaPortfolio.NashvilleHousing

ALTER TABLE Method56dbaPortfolio.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------------------------

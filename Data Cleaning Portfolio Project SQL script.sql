/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- Use row with same ParcelID but different UniqueID to replace 'null' in PropertyAdress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]



--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing4

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing 
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) 

Select *
From PortfolioProject.dbo.NashvilleHousing


-- Other method using PARSENAME

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing 
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) AS row_num
From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Select * --Delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

/*
Careful - In general, you do not delete initial data !
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate











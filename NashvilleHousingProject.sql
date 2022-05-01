--Data cleaning project
--By Md Ahmed Khan
----------------------------------------------------------

--Checking if our data was imported correctly 
SELECT *
FROM   nashvillehousing.dbo.Sheet1$ 



/*
Changing date format
Right now SaleDate has both the date and the timestamp within the column 
We can convert the column to only include DATE instead of DATETIME 
*/
--Looking at the date
SELECT Saledate,
       CONVERT(Date, Saledate)
FROM   nashvillehousing.dbo.Sheet1$


--Converting type to only include date
UPDATE nashvillehousing.dbo.Sheet1$
SET    Saledate = CONVERT(Date, Saledate)


--for some reason CONVERT was not working so we will make a seperate column
ALTER TABLE nashvillehousing.dbo.Sheet1$
  ADD Saledateconverted Date;

UPDATE nashvillehousing.dbo.Sheet1$
SET    Saledateconverted = CONVERT(Date, Saledate)

UPDATE nashvillehousing.dbo.Sheet1$
SET    Saledate = Cast(Saledate AS Date)


--Checking if it worked
SELECT SaleDate,
       Cast(Saledate AS Date)
FROM   nashvillehousing.dbo.Sheet1$ 



/*
Property address update if owners share same ParcelID make parcelid=missing address
*/
SELECT a.Parcelid,
       a.Propertyaddress,
       b.Parcelid,
       b.Propertyaddress,
       Isnull(a.Propertyaddress, b.Propertyaddress)
FROM   nashvillehousing.dbo.Sheet1$ a
       JOIN nashvillehousing.dbo.Sheet1$ b
         ON a.Parcelid = b.Parcelid
            AND a.[UniqueID ] != b.[UniqueID ]
WHERE  a.Propertyaddress IS NULL


UPDATE a
SET    PropertyAddress = Isnull(a.Propertyaddress, b.Propertyaddress)
FROM   nashvillehousing.dbo.Sheet1$ a
       JOIN nashvillehousing.dbo.Sheet1$ b
         ON a.Parcelid = b.Parcelid
            AND a.[UniqueID ] != b.[UniqueID ]
WHERE  a.Propertyaddress IS NULL 



/*
Seperating address into 3 colums (house number, city and state)
*/
SELECT Propertyaddress
FROM   nashvillehousing.dbo.Sheet1$


SELECT Propertyaddress,
       Substring(Propertyaddress, 1, Charindex(',', Propertyaddress) - 1) AS
       address,
       Substring(Propertyaddress, Charindex(',', Propertyaddress) + 1, Len(
       Propertyaddress))                                                  AS
       city
FROM   nashvillehousing.dbo.Sheet1$  

--create new columns for our new data to be inserted into and update them with data
ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
  ADD Addresssplit NVARCHAR(255)

UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET    AddressSplit = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)

ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
  ADD Citysplit NVARCHAR(255)

UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET    CitySplit = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(
                   PropertyAddress))

--different way to cut data into columns so its mroe usable using pasename and replacing periods for commas
SELECT owneraddress,
       Parsename (Replace(owneraddress, ',', '.'), 3) AS house,
       Parsename (Replace(owneraddress, ',', '.'), 2) AS city,
       Parsename (Replace(owneraddress, ',', '.'), 1) AS state
FROM   NASHVILLEHOUSING.DBO.Sheet1$

ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
  ADD OwnerStreetAddress NVARCHAR(255)

UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET    OwnerStreetAddress = Parsename (Replace(owneraddress, ',', '.'), 3)

ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
  ADD OwnerCity NVARCHAR(255)

UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET    OwnerCity = Parsename (Replace(owneraddress, ',', '.'), 2)

ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
  ADD OwnerState NVARCHAR(255)

UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET    OwnerState = Parsename (Replace(owneraddress, ',', '.'), 1) 



/* 
Changing vacant information, from inputs such as Y and N we will update it to Yes or No for consistency
*/
--Seeking the different variances
SELECT DISTINCT( SoldAsVacant ),
               Count(SoldAsVacant)
FROM   NASHVILLEHOUSING.DBO.Sheet1$
GROUP  BY SoldAsVacant
ORDER  BY 2 


--Change letters to words using case statement
SELECT SoldAsVacant,
       CASE
         WHEN SoldAsVacant = 'y' THEN 'Yes'
         WHEN SoldAsVacant = 'n' THEN 'No'
         ELSE SoldAsVacant
       END AS SoldAsVacantUpdated
FROM   NASHVILLEHOUSING.DBO.Sheet1$ 


--update the table
UPDATE NASHVILLEHOUSING.DBO.Sheet1$
SET SoldAsVacant= CASE
         WHEN SoldAsVacant = 'y' THEN 'Yes'
         WHEN SoldAsVacant = 'n' THEN 'No'
         ELSE SoldAsVacant
       END



/*
Removing Duplicate data 
*/
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NASHVILLEHOUSING.DBO.Sheet1$
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



/*
Deleting unnecessary columns from the data
*/
Select *
From NASHVILLEHOUSING.DBO.Sheet1$

ALTER TABLE NASHVILLEHOUSING.DBO.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
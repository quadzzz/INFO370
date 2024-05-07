USE Team8NordstromDB
GO



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Stored Procedure 1 (add)
CREATE OR ALTER PROCEDURE uspInsertCustomerBAP
    @CustID INT,
    @CustTypeID INT,
    @CustFName VARCHAR(50),
    @CustLName VARCHAR(50),
    @CustEmail VARCHAR(100),
    @CustAddress VARCHAR(255),
    @CustDateOfBirth DATE
AS 
BEGIN 
    SET IDENTITY_INSERT tblCustomer ON;
    INSERT INTO tblCustomer (CustID, CustTypeID, CustFName, CustLName, CustEmail, CustAddress, CustDateOfBirth)
    VALUES (@CustID, @CustTypeID, @CustFName, @CustLName, @CustEmail, @CustAddress, @CustDateOfBirth);
    SET IDENTITY_INSERT tblCustomer OFF;
END; 
EXEC uspInsertCustomerBAP
    @CustID = 3002, 
    @CustTypeID = 2,
    @CustFName = 'BLAKE',
    @CustLName = 'PUDISTS',
    @CustEmail = 'blakepudists@uw.com',
    @CustAddress = '1711 2208 Main St',
    @CustDateOfBirth = '2002-05-22';

SELECT * FROM tblCustomer WHERE CustFName = 'Blake' AND CustID = 3002


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stored procedure 2 (remove)
GO
CREATE OR ALTER PROCEDURE uspDeleteCustomer
    @CustID INT
AS 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM tblCustomer WHERE CustID = @CustID)
    BEGIN
        RAISERROR('Customer with CustID d does not exist.', 16, 1, @CustID);
        RETURN;
    END

    DELETE FROM tblCustomer WHERE CustID = @CustID;
END; 
GO

EXEC uspDeleteCustomer
    @CustID = 2001 
GO

SELECT * FROM tblCustomer WHERE CustID = '2001'


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stored Procedure 2--
GO
CREATE OR ALTER PROCEDURE uspInsertCustomer
    @CustomerID INT OUTPUT,
    @CustomerTypeID INT,
    @CustomerName VARCHAR(100)
AS 
BEGIN 
    IF @CustomerTypeID IS NULL OR @CustomerName IS NULL
    BEGIN
        RAISERROR('CustomerTypeID and CustomerName atre NULL.', 16, 1);
        RETURN;
    END

    INSERT INTO Customer (CustomerTypeID, CustomerName)
    VALUES (@CustomerTypeID, @CustomerName);

    SET @CustomerID = SCOPE_IDENTITY();
END;

GO 


--Stored Procedure 3 insert into shipping and 
GO
CREATE OR ALTER PROCEDURE uspInsertShipping
    @ShippingID INT,
    @ShippingAddress VARCHAR(50), 
    @ShippingState VARCHAR(50), 
    @ShippingZIP INT
AS 
BEGIN 
    IF @ShippingAddress IS NULL
    BEGIN
        RAISERROR('ShippingAddress cannot b NULL.', 16, 1);
        RETURN;
    END
    INSERT INTO tblShipping (ShippingAddress, ShippingState, ShippingZIP)
    VALUES (@ShippingAddress, @ShippingState, @ShippingZIP);
END;
GO

EXEC uspInsertShipping
    @ShippingID = 1,
    @ShippingAddress = '2494 Gabriella lane',
    @ShippingState = 'California',
    @ShippingZIP = 12233
GO

SELECT * FROM tblShipping s WHERE s.ShippingState = 'California' AND s.ShippingZIP = 12233; 


-- Stored Procedure 4(showing our joins working)

SELECT * FROM tblCustomerType
GO
CREATE OR ALTER PROCEDURE uspGetCustomerOrders
AS
BEGIN
    SELECT 
        CT.CustTypeID,
        CT.CustTypeDescription,
        C.CustID,
        C.CustFName,
        C.CustLName
    FROM tblCustomer C
    JOIN tblCustomerType CT ON C.CustTypeID = CT.CustTypeID
END;

EXEC uspGetCustomerOrders; 

--------------------------------------------------------------------------------------------------------------------------------------------------
--check constraint if the shipping address is null-- 
GO
IF EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'dbo.CHECK_noninsertedShippingAD'))
    ALTER TABLE tblShipping DROP CONSTRAINT CHECK_noninsertedShippingAD;
GO
ALTER TABLE tblShipping
ADD CONSTRAINT CHECK_noninsertedShippingAD
CHECK (ShippingAddress IS NOT NULL);

BEGIN TRY
    INSERT INTO tblShipping (ShippingAddress, ShippingState, ShippingZIP)
    VALUES (NULL, 'California',12233);
END TRY
BEGIN CATCH
    PRINT 'error! ';
END CATCH;

-----------------------------------------------------------------------------------------------------------------------------
--check constraint 2 when custfname is null--
IF EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'dbo.CHECK_noninsertedCustFName'))
    ALTER TABLE tblCustomer DROP CONSTRAINT CHECK_noninsertedCustFName;
GO

ALTER TABLE tblCustomer
ADD CONSTRAINT CHECK_noninsertedCustFName
CHECK (CustFName IS NOT NULL);
----------------------------------------------------------------------------------------------------------------------------------------------
--created column 1--
ALTER TABLE tblCustomer
ADD CombinedName AS (CONCAT(CustFName, ' ', CustLName)); 

SELECT * FROM tblCustomer

------------------------------------------------------------------------------------------------------------------------
--computed column 2---------
GO
SELECT
    S.ShippingState,
    COUNT(*) AS TotalShipments
FROM
    tblShipping AS S
GROUP BY
    S.ShippingState;


SELECT * FROM tblShipping


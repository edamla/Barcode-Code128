/****** Object:  UserDefinedFunction [dbo].[inffn_encode128]    Script Date: 24.10.2019 19:00:44 ******/

Create FUNCTION [dbo].[inffn_encode128]
(
	@stringToEncode Varchar(255)
)
RETURNS Varchar(255)
AS
BEGIN


DECLARE @encodedString AS VARCHAR(200)  =''        
   
IF LEN(@stringToEncode) > 0
BEGIN
 
;with mycte as
 
(
Select 1 as i 
  
, @stringToEncode as stringToEncode 
,   SUBSTRING(@stringToEncode, 1, 1)   as currentPair 
,Cast(CAST(CHAR(204) as varchar(200)) +  SUBSTRING(@stringToEncode,  1, 1)    as varchar(200)  ) AS encodedString
, (ascii( SUBSTRING(@stringToEncode, 1, 1) )-32 ) as checkSumTotal 
 
Union all
 
Select m.i+1 as i  
,m.stringToEncode 
, SUBSTRING(m.stringToEncode, m.i+1, 1)  
,Cast(m.encodedString +  SUBSTRING(stringToEncode, m.i+1, 1)      as varchar(200)  )
,m.checkSumTotal +  (m.i +1) *(ascii(SUBSTRING(stringToEncode, m.i+1, 1) )-32)
  
FROM mycte m
 
WHERE m.i<=len(@stringToEncode)
)
 
,mycte1 as (
Select encodedString, checkSumTotal, ((104+checkSumTotal) % 103) as mycheckSum , row_number() Over(Order by i DESC) rn from mycte) 
 
Select @encodedString= Cast(encodedString +  CHAR( mycheckSum + (CASE WHEN mycheckSum < 95 THEN 32 ELSE 100 END)) + CHAR(206) as varchar(200))    
from mycte1
WHERE rn=2
 

 
END
return @encodedString 



END


GO



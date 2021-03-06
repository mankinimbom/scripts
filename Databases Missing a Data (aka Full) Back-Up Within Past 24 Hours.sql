--Databases Missing a Data (aka Full) Back-Up Within Past 24 Hours 
------------------------------------------------------------------------------------------- 
--Databases with data backup over 24 hours old 
SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name, 
   MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date, 
   DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS [Backup Age (Hours)] 
FROM 
   msdb.dbo.backupset 
WHERE 
   msdb.dbo.backupset.type = 'D'  
GROUP BY 
   msdb.dbo.backupset.database_name 
HAVING 
   (MAX(msdb.dbo.backupset.backup_finish_date) < DATEADD(hh, - 24, GETDATE()))  

UNION  

--Databases without any backup history 
SELECT      
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,  
   master.sys.sysdatabases.NAME AS database_name,  
   NULL AS [Last Data Backup Date],  
   9999 AS [Backup Age (Hours)]  
FROM 
   master.sys.sysdatabases 
   LEFT JOIN msdb.dbo.backupset ON master.sys.sysdatabases.name = msdb.dbo.backupset.database_name 
WHERE 
   msdb.dbo.backupset.database_name IS NULL 
   AND master.sys.sysdatabases.name <> 'tempdb' 
ORDER BY  
   msdb.dbo.backupset.database_name 
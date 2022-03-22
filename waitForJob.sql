
USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [jobs].[waitForJob]
@name as nvarchar(128)
as
set nocount on;
while Monitor.jobs.jobStatus(@name) != 'Succeeded' waitfor delay '00:01:00'
;
GO

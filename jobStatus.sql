USE [Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [jobs].[jobStatus]
(@name as nvarchar(128))
returns nvarchar(128)
as
begin
declare @status varchar(11);
--assume that session_id always increases with agent_start_date
--get the last session_id that recorded at least a started execution (.run_requested_date is not null)
--because if SQL Agent restarts you get a new id with null values in all columns

with activeSessions as (
	select j.job_id jobID, j.name jobName, a.run_requested_date, a.start_execution_date, a.session_id, s.agent_start_date
	from msdb.dbo.sysjobs j 
	inner join msdb.dbo.sysjobactivity a on j.job_id = a.job_id
	inner join msdb.dbo.syssessions s on a.session_id = s.session_id
	where 1=1
	and a.run_requested_date is not null
) 
,lastActiveSessions as (
	select jobID, jobName,  max(session_id) session_id
	from activeSessions
	group by jobID, jobName
)

select @status = case run_status
when 0 then 'Failed'
when 1 then 'Succeeded'
when 2 then 'Retry'
when 3 then 'Cancelled'
when 4 then 'In Progress'
else		'In Progress'
end
from msdb.dbo.sysjobs j 
inner join msdb.dbo.sysjobactivity a on j.job_id = a.job_id 
inner join lastActiveSessions las on j.job_id = las.jobID and a.session_id = las.session_id
left join msdb.dbo.sysjobhistory h on a.job_id = h.job_id and a.job_history_id = instance_id
where 1=1
and j.name = @name
return @status
end

;


GO

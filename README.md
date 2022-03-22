# waitForJob

This simple stored procedure enables a basic kind of SSIS job SEQ/PAR concurrency control à la [Occam](https://en.wikipedia.org/wiki/Occam_(programming_language)).  Of course, this is very rudimetary, so don't think proper [CSP](https://en.wikipedia.org/wiki/Communicating_sequential_processes).

You can take a single SSIS job and make the steps run in parallel by putting each step into a new separate job: in place of those steps in the original sequential job, you start each of these little secondary jobs using [`sp_start_job`](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-start-job-transact-sql?view=sql-server-ver15).  You can do this all in one TSQL step, but it makes the job clearer if each is started in its own step.  This is all well and good if you have nothing else dependent on these other steps, but if you have a later step that requires any of these complete first then you're scuppered.  Here this procedure helps. Call this procedure, passing it the name of the job you are waiting for, and it will wait until the job has succeeded.  If the job being waited for fails, this procedure will just continue to wait—fix the problem, restart that failed job and this will procedure still continue to wait until that job finishes successfully.

Yes, you can do this kind of control within SSIS packages, but doing it in jobs makes it easily visible to anyone with access to the SQL Agent Manager or another view such as [jobForAttention](https://github.com/iywsdrdiy/jobsForAttention).

If you name your jobs thoughtfully, status becomes very obvious.  Giving the outer job and the inner concurrent ones the same prefix name keeps them all together in the Agent Manager, thus:
+ CPO__midweek_delta
+ CPO__weekend_full
+ CPO_Cloud
+ CPO_Lines
+ CPO_VAS
The first two are the main controlling jobs.  The double underscore ensures they sit first alphabetically.

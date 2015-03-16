USE oceantune_wui;
SELECT endtime 
FROM schedule 
WHERE clean_time IS NULL AND username<>"admin"
ORDER BY endtime DESC
LIMIT 1 INTO @lastest_end_time; 

SELECT endtime
FROM schedule
WHERE endtime < timestamp(now()) AND endtime=@lastest_end_time
LIMIT 1 INTO @target_end_time;

UPDATE schedule 
SET clean_time = 
(
    SELECT NOW()
)
WHERE clean_time IS NULL AND endtime=@target_end_time; 

SELECT username 
FROM schedule 
WHERE endtime = @target_end_time;

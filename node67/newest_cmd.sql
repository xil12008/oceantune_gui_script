USE oceantune_wui;
SELECT create_time 
FROM command_list 
WHERE execute_time IS NULL AND node_id=67
ORDER BY create_time DESC
LIMIT 1 INTO @create_time; 

UPDATE command_list 
SET execute_time = 
(
    SELECT NOW()
), create_time=@create_time
WHERE execute_time IS NULL AND create_time=@create_time; 

SELECT command 
FROM command_list 
WHERE create_time = @create_time;

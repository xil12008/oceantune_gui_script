<snippet>
# OceanTune GUI telnet scripts

On the back-end, there are two main components consisting the server side software, remote control module and environment monitoring module. To achieve remote control, a virtual telnet connection is built in the web-based GUI with time management and user control. Underwater environment monitoring module is implemented to collect sensing data from the nodes equipped with sensors. The connection between server and acoustic nodes is multiplexed so that data collections and remote control works parallelly.

A telnet connection is initialized by Linux server with Intel(R) Xeon(TM) CPU (3.00GHz) to remotely control nodes. Linux server occupied this telnet connection and allow only one user to use this connection during assigned time slots through web-based interface. Processors  created by user will be killed after once the time expired before the usage permission is switched to next user. Linux commands typed on the web interface are stored in the MySQL database and send through telnet connection to remote nodes. The response of these commands is sent back to server and displayed on web interface. 

Sensing data with certain format will be parsed by background program periodically and inserted into MySQL database. The frequency background program checking remote sensing data is configured to match the sensing data generation rate. So higher energy efficiency is preserved while sensing data is collected in real-time. In addition, if data entry received at server side fails to be correctly interpreted, this data entry will be collected in the proceeding period. At the front-end, the most updated sensing data will be displayed using LAMP to user in web GUI.

## Installation

Before installation, a telnet connection should be built between web-server and target system. It would be suggested that you could test the your telnet connection. 

```
telnet <target system ip address>
Type your account name
Password:
```

Simply downloading this repo and under the local clone path you could run the command to initiate a telnet connection to remote machine.

```
sh start.sh <target system ip address> <node ID>
```
 
where ` <target system ip address>` is the IP address of the target system and `<node ID>` is a node ID which is stored in the database. For example, if we use Husky server husky.engr.uconn.edu as our web server and telnet to Mirror server mirror.engr.uconn.edu. And the node ID is 65. Then we should type `sh start.sh mirror.engr.uconn.edu 65`  
 
This command could be run in the background and forwards all the information to a logfile.
```
sh start.sh <target system ip address1> <node ID> >>> logfile1.txt &
sh start.sh <target system ip address2> <node ID> >>> logfile2.txt &
```

After the back-end telnet shell scripts is running, you could type commands on the `<OceanTune GUI URL>/cmd.php?nodeid=65` in your browser. Note that it supports multiple telnet connections at the same time. 

## start.sh 

Before we introduce every scripts code, we talks about what doese `start.sh` do. 
This is the structure of this repo, 

```
nodetemplate/
├── clean_task.sql
├── mysql_connect_clean.sh
├── mysql_connect.sh
├── newest_cmd.sql
├── README
└── telnet_none_filtering.sh
README.md 
start.sh 
```

When you type `sh start.sh <target system ip address> <node ID>`, Linux shell script start.sh will create a node folder with name `node<node ID>` and copy all the files in folder `nodetemplate` to it. In addtion, keyword `IPADDRESS` in scripts in `nodetemplate` will be replaced by specific ip address `<target system ip address>` you typed and NODEID by `<node ID>` you typed. 

For example, after you type the command `sh start.sh mirror.engr.uconn.edu 65`, the file structure will be like:

```
node65/
├── clean_task.sql
├── mysql_connect_clean.sh
├── mysql_connect.sh
├── newest_cmd.sql
├── README
└── telnet_none_filtering.sh
nodetemplate/
├── clean_task.sql
├── mysql_connect_clean.sh
├── mysql_connect.sh
├── newest_cmd.sql
├── README
└── telnet_none_filtering.sh
start.sh 
README.md 
```

Then start.sh will run the `telnet_none_filtering.sh` in folder `node65` to build the telnet connection to `mirror.engr.uconn.edu`. You could also manually run 
`telnet_none_filtering.sh` to start the telnet connection. It's recommended thatyou use start.sh to initiate the telnet connection except you did some node-specific operation of some scripts inside node's folder, in which case you should manually run `telnet_none_filter.sh`. It's because `start.sh` will remove and re-create a folder if folder with same name is detected.

## Scripts
When a new command in the database should be fetched, the call sequence of script is:
``` 
telnet_none_filtering.sh --> mysql_connect.sh --> newest_cmd.sql
```

`telnet_none_filtering.sh` will call mysql_connect.sh as a script to output the newest command and that command is stored as a variable `var` in this script. If no new command is stored in the database, then that variable `var` is empty and `telnet_none_filtering.sh` checks if sensing data should be parsed or user schedules expires. Otherwise, this new command will be output throught linux pipe to telnet. The output of telnet is forwarded though pipe to `tee` which send the output to both user's terminal and text file `result2.txt`. 

When user schedule expires, the call sequence of script is:
```
telnet_none_filtering.sh --> mysql_connect_clean.sh --> clean_task.sql
```

If user schedule expires, which means the end timestamp of user schedule is larger than the timestamp now, `clean_task.sql` will output the user name whose scheulde expire. Note that this script will not return admin ad user name. 

Once `telnet_none_filtering.sh` gets the user name whose schedule expires, it will kill all the processed created by this user.


## Command Track (from browser to MySQL database)

Now, let's look into the code how a command typed in the user browser is sent to remote system through telnet connection and finally display the response using php code. The steps would be: login on login.php as admin, assign user a time slot, type a command on cmd.php, command sent to cmd_request.php, store in database, sent by back-end scripts, display respond on cmd.php. We will show the code that actually executed in these steps with explantion.

At the beginning, user will log on the system using their account. User privilege 0 corresponds to admin, 3 corresponds to user:

```
// login.php
if(!($_REQUEST['username']=== NULL) ){//login~~~
	while ( $row = mysql_fetch_array($result)) {
		echo $row["user_id"]." ".$row["user_name"]." <br />";
		if($row["user_name"]==$_REQUEST['username']){
			if($row["passcode"]==$_REQUEST['passcode']){
				$_SESSION['username'] = $_REQUEST['username'];
				$_SESSION['userflag'] = $row["privilege"];
				echo "SUCESS!Welcome ";
				if($_SESSION['userflag'] == '0') echo "Admin ";
				echo $_SESSION['username'];
				break;
			}
		}
	}
}
else{
	echo "Please Login!";	
}
```

After we login as admin, the next steps is to assign user a specific time slot (Only admin is allowed to do so).

Here we need to check if there is time slots overlapping with others. If there is overlapped period, then we could not insert such a time slot.

```
//schedule_admin.php

if (!is_null($_REQUEST['username']) && !is_null($_REQUEST['starttime']) && !is_null($_REQUEST['hours']) && !is_null($_REQUEST['node']) ) {
	if($_SESSION['userflag']==0) {
		
		$starttime = strtotime($_REQUEST['starttime']);
		
		$endtime = date( "Y-m-d H:i:s", strtotime($_REQUEST['starttime']) + $_REQUEST['hours'] * 3600 );
						
		$result2 = mysql_query("SELECT * FROM schedule WHERE node=".$_REQUEST['node'], $connection);
		while($row2 = mysql_fetch_array($result2)) {
			$starttime2 = strtotime($row2['starttime']);
			$endtime2 = strtotime($row2['endtime']);
			//var_dump($starttime>$endtime2);
			//echo "<br>";
			//var_dump(strtotime($_REQUEST['starttime']) + $_REQUEST['hours'] * 3600>$starttime2);
			//echo "<br>";
			if(($starttime-$endtime2)*(strtotime($_REQUEST['starttime']) + $_REQUEST['hours'] * 3600-$starttime2) <=0 ) {
				die("Invalid schedule. Time slot overlapped.");	
			}
		}
		
		$result3 = mysql_query("INSERT INTO schedule (username, starttime, endtime, node) VALUES ('".$_REQUEST['username']."', '".$_REQUEST['starttime']."','".$endtime."',".$_REQUEST['node'].")");	
		if(!$result3) {
			die('Invalid Query:'.mysql_error());	
		}
		echo "You have added a new time slot.<br />";
	}
	else{
		echo "Permission Denied! Please contact administraters! <br />";
	}
}
```

Successfully assign user time slots, then login as that user. So we could now type a command on cmd.php.

Javascript function send_cmd(frm, kCmd) will be called in this step. The command user typed in the will be sent using ajax to web server. After that command is sent, this page will refresh in 1000ms so that the response could be display. We will look in to the code for display reponse later.

```
//cmd.php

function send_cmd(frm, kCmd)
{
	xmlhttp=new XMLHttpRequest();
	xmlhttp.onreadystatechange=function()
	{
	  if (xmlhttp.readyState==4 && xmlhttp.status==200)
		{
			console.log("remote:"+xmlhttp.responseText);
			if(xmlhttp.responseText.indexOf("Permission denied") > -1) {
				alert("Permission denied. Please ask administrator for next avaialble time slots.");
			}
		}
	}
	
	if(kCmd){
		cmd=""	//empty for now
	}
	else{
		cmd=frm.command.value;
	}
	xmlhttp.open("GET","cmd_request.php?q="+cmd,true);
	xmlhttp.send();
	
	setTimeout(function(){window.location.href="cmd.php"}, 1000);
}
```

This is the php code for parsing the ajax request.
The command stores in `$q` will be inserted into the MySQL database in table commmand_list.

```
//cmd_request.php

$insert_cmd_result = mysql_query("INSERT INTO command_list (command, create_time, username)
	VALUES ('".$q."', '".date('Y-m-d H:i:s', strtotime("now"))."','"."developer"."')");
if(!$insert_cmd_result) {
	die("Insert cmd failed! ".mysql_error());
} else {
    echo "Succeed";	
}
```

At this point, the command is already sent to the MySQL database on the webserver, with timestamp and corresponding node ID.

## Command Track (from database to telnet)

```

```

## Command Track (display response)

The `cmd.php` code display the result.txt file which contains the response the telnet scripts.
In the newer version, we also format the response into html table `<table></table>` so that the content looks aligned.
```
//cmd.php

$file = "/home/xiaoyan/result2.txt";
$file = escapeshellarg($file); // for the security concious (should be everyone!)
$line100 = `tail -n 300 $file | grep -v 'tail -n 1 logfile' | grep -v 'bathroom' | grep -v 'logfile' | grep -v 'oceantune' | grep -v 'clean'  `;
	
$dictionary = array(
	'[0m' => '',
	'[01;34m' => '',
	'[30;42' => '',
	']0;'   => '' ,
	'[01;36m' => '' ,
);
$htmlString = str_replace(array_keys($dictionary), $dictionary, $line100);

echo nl2br(htmlspecialchars($htmlString));
```


## TODO lists

1. The user management/login php code is insecure at all.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

TODO: Write history

## Credits

TODO: Write credits

## License

TODO: Write license
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>

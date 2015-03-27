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

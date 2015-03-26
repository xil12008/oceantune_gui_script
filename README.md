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
sh start.sh <target system ip address> >>> logfile.txt &
```

## Usage

This is the structure of files 

```
nodetemplate/
├── clean_task.sql
├── mysql_connect_clean.sh
├── mysql_connect.sh
├── newest_cmd.sql
├── README
└── telnet_none_filtering.sh
README.md [error opening dir]
start.sh [error opening dir]
```

Linux shell script start.sh will copy 

## Scripts

### start.sh

###

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

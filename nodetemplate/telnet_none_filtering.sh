{
sleep 1
echo oceantune 
sleep 3
echo whatever 
sleep 3
echo 'cd /home/oceantune'
sleep 1
echo 'su - oceantuneuser'
sleep 1
echo whatever
sleep 1
COUNTER=0
COUNTER2=0
while [  $COUNTER -lt 10 ]; do
   var=$(sh mysql_connect.sh)
   len=$(echo ${#var})
   if [ $len -lt 1 ]; then
      if [ $COUNTER2 -lt 999 ]; then 
          COUNTER2=$[$COUNTER2+1]
      else
          echo 'tail -n 1 logfile'
          COUNTER2=0
      fi
      cleanuser=$(sh mysql_connect_clean.sh)
      lenuser=$(echo ${#cleanuser})
      if [ $lenuser -ge 1 ]; then
          echo 'su - oceantune'
          sleep 1 
          echo 'whatever'
          sleep 1 
          echo 'sh cleanprocess.sh'
          sleep 1 
          echo 'su - oceantuneuser'    
          sleep 1 
          echo 'whatever'
      fi
   elif [ "$var" = "ctrlplusc" ]
   then
	echo $'\cc' 
   else 
      echo $var
   fi
done
} | telnet IPADDRESS | tee result2.txt 

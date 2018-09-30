#!/bin/bash


stopService(){
  exec="systemctl stop agentService.service"
  $exec

  exec="systemctl disable agentService.service"
  $exec

  exec="rm /etc/systemd/system/agentService.service"
  $exec

  exec="systemctl daemon-reload"
  $exec

  exec="systemctl reset-failed"
  $exec
}

uninstall(){
 
getValue "serviceFile"    
# getValue "removeProcessCmd"    


# value of serviceFile was saved at the time of agent installation and it may be
# agent_controller.sh or agent_controller.service or agent_controller_ubuntu.sh
echo "serviceFile = : $serviceFile"



# Since serviceFile file exist in /etc/init.d/ directory. So ensure proper file MUST BE EXIST( to 
# ignore accidental deletion of entire contents in /etc/init.d folder)
# if [[ $serviceFile != *"agent_controller"*  ||
#          $removeProcessCmd != *"agent_controller"* ]]; then
#    echo "No valid service file found. Abort process..."
#    exit 1
# fi

if [[ $serviceFile != *"agent_controller"* ]]; then
   echo "No valid service file found. Abort process..."
   exit 1
fi


if [ "$isProcessRunning" -gt 0 ]; then
  echo "Killing the process..."
  stopService
  # killTheProcess
else
   echo "Detected - Agent already stopped."
fi


# Restrict service to restart on reboot
# On the basis of linux type either it has update-rc.d -f ... or chkconfig --del  ....
# value of removeProcessCmd was saved at the time of agent installation
echo "Restrict process to restart on reboot..."
# $removeProcessCmd 


echo "Deleting /opt/infraguard/ directory..."
command="rm -rf /opt/infraguard/"
$command


echo "Deleting /var/logs/infraguard/ directory..."
command="rm -rf /var/logs/infraguard/"
$command

echo "Deleting service file at /etc/init.d/$serviceFile..."
command="rm -rf /etc/init.d/$serviceFile"
$command

echo ""
echo "****************** Uninstallation process completes. *******************"

} #Uninstall


# Read the given 'key' from /opt/infraguard/etc/agentInfo.txt file
# On the basis of key, shared variable will be initialized and uses in uninstall() method.
getValue(){
   key="$1"
   while IFS= read -r line; do

      if [[ $line == *"$key"* ]]; then
         val=${line/$key=/""}    
   
         if [[ $line == "serviceFile"* ]]; then
              serviceFile=$val
         fi

         # if [[ $line == "removeProcessCmd"* ]]; then
         #      removeProcessCmd=$val
         # fi

         break;
      fi

  done < "$fileName"
}


determineProcessRunningOrNot(){
   PID=$(ps -ef | grep 'infraGuardMain' | grep -v 'grep' | awk '{ printf $2 }')
   
   ps --pid $PID &>/dev/null
   if [ $? -eq 0 ]; then
      isProcessRunning=1
      echo "Agent is running & its PID = : $PID"
   else
      isProcessRunning=0
   fi

} # DetermineProcessRunningOrNot


# killTheProcess(){
#    echo "Going to kill process id = : $PID by using normal signal."
#    echo "Signal -9 will be fire only after 10 seconds if unable to kill process normally ... "
   
#    # Number of seconds to wait before using "kill -9"
#    WAIT_SECONDS=10

#    # Counter to keep count of how many seconds have passed
#    count=0

#    while kill $PID > /dev/null
#    do
#        # Wait for one second
#        sleep 1
#        # Increment the second counter
#        ((count++))

#        # Has the process been killed? If so, exit the loop.
#        if ! ps -p $PID > /dev/null ; then
#            break
#        fi

#        # Have we exceeded $WAIT_SECONDS? If so, kill the process with "kill -9"
#        # and exit the loop
#        if [ $count -gt $WAIT_SECONDS ]; then
#            kill -9 $PID
#            break
#        fi
#    done
#    echo "Process has been killed after $count seconds."
# }

# Check whether user has root level access or not.
if [ `id -u` -ne 0 ] ; then
            echo "error: Agent uninstallation process requires superuser privilege. Abort process."
            exit 1
fi


# Check whether file existed or not.
fileName="/opt/infraguard/etc/agentInfo.txt" 
if [ ! -f $fileName ]; then
    echo "Missing file $fileName. This file should be created at the time of agent installation."
    exit 1
fi

PID=""
declare -i isProcessRunning=-1
determineProcessRunningOrNot


serviceFile=""
# removeProcessCmd=""
uninstall



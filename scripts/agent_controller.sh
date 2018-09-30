#!/bin/bash


. /etc/init.d/functions

# chkconfig: 35 90 12
# description: Agent Installer Test
#

# Get function from functions library

# Start the service AgentInstaller


start() {

echo ""
echo $"***********  agent_controller service started. Triggered from /etc/init.d/agent_controller.sh ***********"

command="/opt/infraguard/sbin/infraGuardMain"
daemon "nohup $command >/dev/null 2>&1 &"

}


# To execute this from CLI --> /etc/init.d/agent_controller.sh stop
stop(){
echo "Going to kill process agent_controller.sh"
pkill  agent_controller.sh


pId=$(ps -ef | grep 'infraGuardMain' | grep -v 'grep' | awk '{ printf $2 }')
echo "pId = : $pId"
command="/bin/kill -9 $pId"
$command



if [ $? != 0 ]; then                   
   echo "Unable to kill process id $pId" 
else
   command="chkconfig --del agent_controller.sh"
   $command 

   echo "Process $pId killed successfully " 
fi

}



case "$1" in
  start)
        get_osflavor
        start
        ;;
  stop)
        stop
        ;;

status)
        status agent_controller.sh
        ;;

 *)
        echo $"Usage: $0 {start|stop|status}"
        exit 1
esac

exit 0
os=""

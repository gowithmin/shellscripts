#!/bin/sh
# chkconfig: 345 65 55
# description: Startup script of Tokyo Tyrant Server
# processname: tokyotyrant
# hyunmin hwang gowithmin@gmail.com

initScript() {
# Check Program, Basedir
    Prog="/usr/local/bin/ttserver"
    BaseDir="/var/ttserver"

    if [ ! -x $Prog ];then
	echo "[CRIT] $Prog not found"
        exit 1
    fi

    if [ -d ${BaseDir} ];then
	mkdir -p ${BaseDir}
	touch ${BaseDir}/testfile
	if [ $? -ne 0 ];then
	    echo "[CRIT] ${BaseDir} permission check failed"
	    exit 1
	fi
	    rm -f ${BaseDir}/testfile
    fi
	
# for direct run
    Ports=$2    
    if [ -z ${Ports} ];then
        Ports=(1992)
# for multiple
# Ports=(1992 1993)
    fi

# Set environment
    LANG=C
    LC_ALL=C
    PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"
    export LANG LC_ALL PATH

    NoFile=8192
    if [ `ulimit -n` -lt ${NoFile} ];then
	ulimit -n $NoFile > /dev/null 2>&1
    fi
}

SetStartupCommand() {
    Cmd="$Prog"
# Set Tokyo tyrant startup options
    PortNum=${Port}
    if [ -n ${PortNum} ];then
	Cmd="${Cmd} -port ${PortNum}"
    fi

    Threads=8
    if [ -n "${Threads}" ];then
	Cmd="$Cmd -thnum ${Threads}"
    fi

    RunAsDaemon="dmn"
    if [ -n ${RunAsDaemon} ];then
	Cmd="$Cmd -${RunAsDaemon}"
    fi

    PidFile="${BaseDir}/${Port}.pid"
    if [ -n ${PidFile} ];then
	Cmd="$Cmd -pid ${PidFile}"
    fi

    LogFile="${BaseDir}/${Port}.log"
    if [ -n ${LogFile} ];then
        Cmd="$Cmd -log ${LogFile}"
    fi

    LogOpt="le"
    if [ -n "$LogOpt" ]; then
        Cmd="$Cmd -${LogOpt}"
    fi

#UpdateLogDir="${BaseDir}/ulog"
    if [ -n "${UpdateLogDir}" ];then
        mkdir -p "${UpdateLogDir}"
        Cmd="$Cmd -ulog ${UpdateLogDir}"
    fi	

#UpdateLogLimit="256m"
     if [ -n "${UpdateLogLimit}" ];then
         Cmd="$Cmd -ulim ${UpdateLogLimit}"
     fi

#ServerId=1
    if [ -n "${ServerId}" ];then
        Cmd="$Cmd -sid ${ServerId}"
    fi

# for replication
#MasterServer=""
    if [ -n "${MasterServer}" ];then
        Cmd="${Cmd} -mhost ${MasterServer}"
    fi

#MasterPort="1978"
    if [ -n "${MasterPort}" ];then
        Cmd="${Cmd} -mport ${MasterPort}"
    fi

#ReplicatoinTimeStampFile="${BaseDir}/rts"
    if [ -n "${ReplicatoinTimeStampFile}" ];then
        Cmd="${Cmd} -rts ${ReplicatoinTimeStampFile}"
    fi

    DBName="${BaseDir}/casket-${Port}.tch#bnum=10000000"
    if [ -n ${DBName} ];then
	Cmd="${Cmd} ${DBName}"
    fi
}

Start() {
    for ((i=0;i<${#Ports[@]};i++))
    do
        Port=${Ports[$i]}
	SetStartupCommand

	echo "[INFO] Starting Tokyo Tyrant on ${Port}"	
	
	Pid=`lsof -t -i tcp:${Port}`
	if [ -z ${Pid} ];then
	    rm -f ${PidFile}

            echo "[INFO]Command:$Cmd"
            $Cmd

	    if [ $? -eq 0 ];then
		echo "[INFO] Tokyo tyrant started, Pid:${Pid} on Port:${Port}"
	    fi
        else
	    echo "[Warn] Already running at Pid:${Pid} on Port:${Port}"
	fi
	done
}

Stop() {
    for ((i=0;i<${#Ports[@]};i++))
    do
	Port=${Ports[$i]}
	
	Pid=`lsof -t -i tcp:${Port}`
	if [ -z ${Pid} ];then
	    echo "[WARN] Tokyo tyrant is not running on the Port:${Port}"
        else
	    PidFile="${BaseDir}/${Port}.pid"
	    PidOnFile=`cat ${PidFile}`
	    if [ ${Pid} -eq ${PidOnFile} ];then
	        echo "[INFO] Stopping Tokyo Tyrant on Port:${Port}"

		kill -TERM $PidOnFile
# Check stopped
		Cnt=0
		while true;
		do
		    sleep 0.1
		    if [ -f $PidFile ];then
		        Cnt=$((Cnt+1))
		        if [ ${Cnt} -ge 100 ];then
			    echo "[WARN] Stop Pid:${Pid} on Port:${Port} hanging"
			    break
			fi
		    else
	                echo "[INFO] Tokyo tyrant stopped... Pid:${Pid} on Port:${Port}"
			break
		    fi
		done
	    else
	        echo "[WARN] Abnormal status... Pid:$Pid is not equal to Pid of pid file:$PidOnFile... Port:${Port}"
	    fi			
	fi
    done
}

Status() {
    for ((i=0;i<${#Ports[@]};i++))
    do	
	Port=${Ports[$i]}
	Pid=`lsof -t -i tcp:${Port}`

	if [ -z $Pid ];then
	    echo "Tokyo tyrant on Port:${Port} is stopped"
 	else
	    echo "Tokyo tyrant is running on the Port:${Port}"
	fi
    done
}


Hup() {
    for ((i=0;i<${#Ports[@]};i++))
    do
        Port=${Ports[$i]}
        Pid=`lsof -t -i tcp:${Port}`
        if [ -z ${Pid} ];then
            echo "[WARN] Tokyo tyrant is not running on the Port:${Port}"
        else
            PidFile="${BaseDir}/${Port}.pid"
            PidOnFile=`cat ${PidFile}`
            if [ ${Pid} -eq ${PidOnFile} ];then
                echo "[INFO] Sending hangup signal to the Tokyo Tyrant process : ${Pid}"
                kill -HUP $PidOnFile
            else
                echo "[WARN] Abnormal status... Pid:$Pid is not equal to Pid of pid file:$PidOnFile... Port:${Port}"
            fi
        fi
    done
}

## main
initScript

case "$1" in
start)
  Start
  ;;
stop)
  Stop
  ;;
restart)
  Stop
  Start
  ;;
 status)
  Status
  ;;
hup)
  Hup
  ;;
*)
  echo "Usage: $0 {start|stop|status|restart|hup}"
  exit 1
esac

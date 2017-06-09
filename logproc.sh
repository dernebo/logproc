#!/bin/bash
# ©Fredrik Dernebo (fredrik@dernebo.se)
# June 2017
#
# Summary: Log memory and cpu usage of a java-process and log to a file.
# CPU-usage over a certain value logs to a separate warning-file
#
# Usage: ./logproc.sh <processname> <update-time> <cpu-warning-threshold>
#
# Processname can be checked via command 'jps'
# Update-time is how often to write to logfiles.
# CPU-warning-threshold sets when to log to a warning-logfile
#
##########################################################################
# Where to put logfiles
logpath='/Users/laidback/Library/Logs/Logproc/'


##########################################################################
procname=$1
pid=`jps|grep $procname|cut -d" " -f1`
upd=$2
thr=$3
if [[ $pid == "" ]] ; then
        echo
        echo "Error - No arguments given."
        echo 'Usage: ./logproc.sh <pid> <update-time> <warning-thr>'
        exit
fi

if [[ $upd == "" ]] ; then upd=1; fi
if [[ $thr == "" ]] ; then thr=1; fi

echo 'Usage: ./logproc.sh <processname> <update-time> <warning-thr>'
echo 'Update interval: '$upd' seconds'
echo 'Logging PID '$pid' cpu usage to '$logpath'.'
while :
        do
                curtime=`date +%Y-%m-%d:%H:%M:%S`
                curlog=logproc_`date +%Y-%m-%d`.log
                curwarnlog=warn_logproc_`date +%Y-%m-%d`.log
                curuse=`top -l 2 -pid $pid|tail -1|awk '{ print $3 }'`
                curmem=`top -l 2 -pid $pid|tail -1|awk '{ print $8 }'`
                echo $curtime ' - ' $pid 'cpu: '$curuse'% mem: '$curmem>> $logpath$curlog
                warncuruse=$(echo "scale=2; $curuse" | bc -l)
                if (( `echo $warncuruse'>='$thr | bc` ))
                        then echo $curtime ' - ' $pid 'cpu: '$curuse'% mem: '$curmem >> $logpath$curwarnlog
                fi
                sleep $upd;

        done

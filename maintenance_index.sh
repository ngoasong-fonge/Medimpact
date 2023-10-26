#!/bin/bash
#
#This is a script to fork maintenance calls until complete
#

#
#Set variables
#
echo "Did you shut off mega-maid and the backup?"
echo "Please input the mobi password:  "
read -s PGPASSWORD

#
#Noninteractive variables
#
WORKDIR=$(pwd)
SCRIPT2=maintenance_calls_index.sh
DATABASE=mobi
LOGDIR=$(pwd)
LOGFILE="maintenance.log"
i=0

#
#General log information
#
echo "Maintenance is now begining" | tee -a $LOGDIR/$LOGFILE

index_start()
{
#
#Call children
#
    for INDEX in ${INDEXES[@]}
    do
	    PGPASSWORD=$PGPASSWORD $WORKDIR/$SCRIPT2 $DATABASE $INDEX &
	    PIDS[${i}]=$!
	    PROCS[${i}]=$INDEX
	   i=$(expr $i + 1)
    done

#
#Child Monitor
#
    for PID in ${PIDS[*]}
    do
	    wait $PID
    done
}

PIDS=()
INDEXES=(idx_account_controls_lookup index_carrier_line_details_on_account_control_id index_carrier_line_details_on_management_job_id)
index_start

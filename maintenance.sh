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
SCRIPT2=maintenance_calls.sh
TABLES=( )
DATABASE=mobi
LOGDIR=$(pwd)
LOGFILE="maintenance.log"
i=0

#
#General log information
#
echo "Maintenance is now begining" | tee -a $LOGDIR/$LOGFILE

maintenance_start()
{
#
#Call children
#
    for TABLE in ${TABLES[@]}
    do
	    PGPASSWORD=$PGPASSWORD $WORKDIR/$SCRIPT2 $DATABASE $TABLE &
	    PIDS[${i}]=$!
	    PROCS[${i}]=$TABLE
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
#
#Add as many of these as neccesary
#With pids empty to reset array and tables with desired tables
#
PIDS=()
TABLES=( )
maintenance_start

echo "Maintenance is now complete."| tee -a $LOGDIR/$LOGFILE
echo "Please re-enable megamaid." | tee -a $LOGDIR/$LOGFILE
exit 0
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#!/bin/bash
#
# This script performs a VACUUM ANALYZE on multiple tables
#

# Set variables
echo "Did you shut off mega-maid and the backup?"
echo "Please input the PostgreSQL password: "
read -s PGPASSWORD

# Noninteractive variables
WORKDIR=$(pwd)
SCRIPT2=maintenance_calls_vacuum_analyze.sh
DATABASE=mydb
LOGDIR=$(pwd)
LOGFILE="maintenance.log"
i=0

# General log information
echo "Maintenance (VACUUM ANALYZE) is now beginning" | tee -a $LOGDIR/$LOGFILE

# Function to start maintenance for multiple tables
vacuum_analyze_start() {
    # Call children
    for TABLE in ${TABLES[@]}; do
        PGPASSWORD=$PGPASSWORD $WORKDIR/$SCRIPT2 $DATABASE $TABLE &
        PIDS[${i}]=$!
        PROCS[${i}]=$TABLE
        i=$(expr $i + 1)
    done

    # Child Monitor
    for PID in ${PIDS[*]}; do
        wait $PID
    done
}

# Define an array of tables to perform VACUUM ANALYZE on
PIDS=()
TABLES=(table1 table2 table3)

# Start the VACUUM ANALYZE maintenance tasks
vacuum_analyze_start

echo "Maintenance (VACUUM ANALYZE) is now complete." | tee -a $LOGDIR/$LOGFILE
echo "Please re-enable mega-maid." | tee -a $LOGDIR/$LOGFILE
exit 0

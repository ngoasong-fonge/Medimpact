#!/bin/bash
#
#This is a call to perform a maintenance action on the DB
#
export PGDATABASE=$1
export PGUSER=derik.taylor
LOGDIR=$(pwd)
LOGFILE="$2.log"
INDEX=$2
ERROR=0

if ! psql -c "REINDEX INDEX $INDEX" &>> $LOGDIR/$LOGFILE
then
	ERROR=1
fi
if ! psql -c "ANALYZE $INDEX" &>> $LOGDIR/$LOGFILE
then
	ERROR=1
fi
if [ $ERROR == 1 ]
then
	exit 1
else
	exit 0
fi

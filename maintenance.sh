#!/bin/bash
# Source .bash_profile to load environment variables
source /path/to/.bash_profile

# Define other script variables
username="your_db_username"
database="your_db_name"
tables=("table1" "table2" "table3")

start_time=$(date +%s)

for table in "${tables[@]}"; do
   psql -U $username -d $database -c "VACUUM ANALYZE $table"
done

end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to a file
log_file="/path/to/output_directory/vacuum_total_time.log"
echo "Start Time: $(date -d @$start_time)" > $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file

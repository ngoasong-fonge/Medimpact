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
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

# Source .bash_profile to load environment variables
source /path/to/.bash_profile

# Define other script variables
username="your_db_username"
database="your_db_name"
schema="your_schema_name"
tables=("table1" "table2" "table3")
db_host="localhost"  # Use the appropriate host
db_port="5432"      # Use the appropriate port

# Set the maximum number of log files to keep
max_log_files=7  # Adjust as needed

# Create the log directory if it doesn't exist
log_dir="/path/to/output_directory"
mkdir -p "$log_dir"

# Generate a timestamp for the log file
timestamp=$(date +"%Y%m%d%H%M%S")
log_file="$log_dir/vacuum_log_$timestamp.log"

# Function to perform log rotation and deletion
perform_log_rotation() {
  # List log files in the log directory
  log_files=("$log_dir"/vacuum_log_*.log)

  # Calculate the number of log files
  num_log_files=${#log_files[@]}

  # Perform log rotation if the number of log files exceeds the maximum
  if [ "$num_log_files" -gt "$max_log_files" ]; then
    # Sort log files by timestamp in ascending order
    IFS=$'\n' sorted_logs=($(sort <<<"${log_files[*]}"))
    unset IFS

    # Delete the oldest log files to keep the most recent ones
    num_files_to_delete=$((num_log_files - max_log_files))
    for ((i = 0; i < num_files_to_delete; i++)); do
      rm "${sorted_logs[i]}"
    done
  fi
}

# Perform log rotation
perform_log_rotation

# Start measuring script execution time
start_time=$(date +%s)

for table in "${tables[@]}"; do
   psql -h $db_host -p $db_port -U $username -d $database -c "VACUUM ANALYZE $schema.$table"
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time minutes" >> $log_file

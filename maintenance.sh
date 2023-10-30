#!/bin/bash
# Source .bash_profile to load environment variables
source /opt/app/localhome/svcpostgres/pg_env.sh

# Define other script variables
username=svcpostgres
database=citus
schema=ngmep
tables=(enc_ver_raw_compound encounter encounter_ext_dtl encounter_extract encounter_ver_compound encounter_ver_exception encounter_ver_raw encounter_ver_status encounter_version file_transmission file_transmission_error file_transmission_status mep_provider status_ovr_approval)

start_time=$(date +%s)

for table in "${tables[@]}"; do
   psql -h pv2medpg1c1 -d citus -c "VACUUM ANALYZE $schema.$table"
done

end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to a file
log_file="/path/to/output_directory/vacuum_total_time.log"
echo "Start Time: $(date -d @$start_time)" > $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time minutes" >> $log_file
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

# Source .bash_profile to load environment variables
source /opt/app/localhome/svcpostgres/pg_env.sh

# Define other script variables
username=svcpostgres
database=citus
schema=ngmep
tables=(enc_ver_raw_compound encounter encounter_ext_dtl encounter_extract encounter_ver_compound encounter_ver_exception encounter_ver_raw encounter_ver_status encounter_version file_transmission file_transmission_error file_transmission_status mep_provider status_ovr_approval)

# Set the maximum number of log files to keep
max_log_files=7  # Adjust as needed

# Create the log directory if it doesn't exist
log_dir=/opt/app/postgres-data/vacuum_analyze_dr
# mkdir -p "$log_dir"

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
   psql -h pv2medpg1c1 -d citus -c "VACUUM ANALYZE $schema.$table"
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time minutes" >> $log_file

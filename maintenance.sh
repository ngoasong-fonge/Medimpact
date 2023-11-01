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
   psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
done

end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to a file
log_file="/path/to/output_directory/vacuum_total_time.log"
echo "Start Time: $(date -d @$start_time)" > $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file

Not the leader. Skipping VACUUM ANALYZE for ngmep.file_transmission_status.
./vacuum_analyze.sh: line 55: continue: only meaningful in a `for', `while', or `until' loop
VACUUM
----------------------------------------------------Bellow -script- will - rotate- logs-----------------------------------------------------------------
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
log_dir=/opt/backup/pgprod1/vacuum_analyze
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
   psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file

---------------------------------------Bellow script will check if the PostgreSQL instance is not the standby leader or master before executing the VACUUM ANALYZE operation ------------------------------------------

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
log_dir=/opt/backup/pgprod1/vacuum_analyze
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

# Function to check PostgreSQL role
check_postgres_role() {
  patroni_status=$(curl -s ${PATRONI_IP}:8008)
  role=$(echo $patroni_status | jq -r '.role')

  if [[ "$role" != "standby_leader" ]] && [[ "$role" != "master" ]]; then
    echo "Not the leader. Skipping VACUUM ANALYZE for $schema.$table."
    continue
  fi
}

# Start measuring script execution time
start_time=$(date +%s)

for table in "${tables[@]}"; do
  # Call the function to check PostgreSQL role
  check_postgres_role

  # Execute VACUUM ANALYZE if it's the leader
  psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file

---------------------------------------------------------------------------------------------------------edited version--------------------------------------

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
log_dir=/opt/backup/pguatdr1/vacuum_analyze
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

# Function to check PostgreSQL role and return status
check_postgres_role() {
  patroni_status=$(curl -s ${PATRONI_IP}:8008)
  role=$(echo $patroni_status | jq -r '.role')

  if [[ "$role" != "standby_leader" ]] && [[ "$role" != "master" ]]; then
    return 1  # Not the leader
  else
    return 0  # It's the leader
  fi
}

# Start measuring script execution time
start_time=$(date +%s)

for table in "${tables[@]}"; do
  # Call the function to check PostgreSQL role
  check_postgres_role

  # Check the return status to decide whether to execute VACUUM ANALYZE
  if [ $? -eq 0 ]; then
    psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
  else
    echo "Not the leader. Skipping VACUUM ANALYZE for $schema.$table."
  fi
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file

----------------------------------------------------------------updated--version with pg_is_in_recovery-------------------------------------------------------------------------

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
log_dir=/opt/backup/pguatdr1/vacuum_analyze
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

# Function to check if the node is the leader
check_postgres_role() {
  # Use pg_is_in_recovery to check if the node is in recovery
  is_leader=$(psql -h localhost -d citus -t -c "SELECT pg_is_in_recovery();")
  
  if [ "$is_leader" == "f" ]; then
    return 0  # It's the leader
  else
    return 1  # Not the leader
  fi
}

# Start measuring script execution time
start_time=$(date +%s)

for table in "${tables[@]}"; do
  # Call the function to check if the node is the leader
  check_postgres_role

  # Check the return status to decide whether to execute VACUUM ANALYZE
  if [ $? -eq 0 ]; then
    psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
  else
    echo "Not the leader. Skipping VACUUM ANALYZE for $schema.$table."
  fi
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> $log_file
echo "End Time: $(date -d @$end_time)" >> $log_file
echo "Total Time: $total_time seconds" >> $log_file
------------------------------------------------------------------------using the the curl command to check role-----------------------------------------------------------------------

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
log_dir=/opt/backup/pguatdr1/vacuum_analyze
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

# Function to check if the node is the leader using Patroni REST API
check_patroni_role() {
  patroni_url="http://localhost:8008"

  # Use curl to query the Patroni REST API for status information
  patroni_status=$(curl -s "$patroni_url")

  # Check the 'role' field in the Patroni status JSON
  role=$(echo "$patroni_status" | jq -r '.role')

  if [ "$role" == "master" ]; then
    return 0  # It's the leader
  else
    return 1  # Not the leader
  fi
}

# Start measuring script execution time
start_time=$(date +%s)

for table in "${tables[@]}"; do
  # Call the function to check if the node is the leader
  check_patroni_role

  # Check the return status to decide whether to execute VACUUM ANALYZE
  if [ $? -eq 0 ]; then
    psql -h localhost -d citus -c "VACUUM ANALYZE $schema.$table"
  else
    echo "Not the leader. Skipping VACUUM ANALYZE for $schema.$table."
  fi
done

# End measuring script execution time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Log the total start and end times to the current day's log file
echo "Start Time: $(date -d @$start_time)" >> "$log_file"
echo "End Time: $(date -d @$end_time)" >> "$log_file"
echo "Total Time: $total_time seconds" >> "$log_file"

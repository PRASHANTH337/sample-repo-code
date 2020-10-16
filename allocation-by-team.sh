#/bin/bash

: '

Copyright (C) 2020 IBM Corporation

Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    Rafael Sene <rpsene@br.ibm.com> - Initial implementation.
'
# Trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "Bye!"
}

function check_dependencies() {
    DEPENDENCIES=(jq awk)

    for i in "${DEPENDENCIES[@]}"
    do
        if ! command -v $i &> /dev/null; then
                echo "$i could not be found, exiting!"
                exit
        fi
    done
}

function process() {
    
    VIRTUAL_LIMIT_MEMORY=2048
    VIRTUAL_LIMIT_CORE=100

    TODAY=$(date +'%m_%d_%Y')
    TIME=$(date +'%r %Z')
    ALLOCATION_FILE=$1
    SORTED_CSV_FILE=$2
    SUMMARY="team_summary_$TODAY.csv"
    SUMMARY_SORTED="team_summary_sorted_$TODAY.csv"

    > ./$SUMMARY
    > ./$SUMMARY_SORTED

    while IFS= read -r line
    do

        local TOTAL_INSTANCES=0
        local TOTAL_PROCESSORS=0
        local TOTAL_MEMORY=0
        local TOTAL_TIER1=0
        local TOTAL_TIER2=0
        local TEAM=$(echo "$line" | awk '{split($0,a,":"); print a[1]}')
        local POWERVS=$(echo "$line" | awk '{split($0,a,":"); print a[2]}')
        IFS=', ' read -r -a POWERVS_ARRAY <<< "$POWERVS"

        local CSV_FILE_SORTED=$TEAM-sorted.csv
        > $TEAM-sorted.csv

        for index in "${!POWERVS_ARRAY[@]}"; do
                cat $2 | grep "${POWERVS_ARRAY[index]}" >> $TEAM.csv
        done

        # Sort the file based on the amount of memory used
        sort -t "," --key 6 --numeric-sort ./$TEAM.csv | grep -v '^null' >> ./$CSV_FILE_SORTED

        # Sets the header for the csv file
        echo "PowerVS ID,PowerVS Name,PowerVS Region,Number of Instances,Allocated Processors,Allocated Memory,TIER1 Usage,TIER3 Usage\n$(cat ./$CSV_FILE_SORTED)" > $CSV_FILE_SORTED

        # Add the total at the end of the sorted .csv
        echo "******,******,******,******,******,******,******,******" >> $CSV_FILE_SORTED

        TOTAL_INSTANCES=$(awk -F"," '{x+=$4}END{print x}' ./$CSV_FILE_SORTED)
        TOTAL_PROCESSORS=$(awk -F"," '{x+=$5}END{print x}' ./$CSV_FILE_SORTED)
        TOTAL_MEMORY=$(awk -F"," '{x+=$6}END{print x}' ./$CSV_FILE_SORTED)
        TOTAL_TIER1=$(awk -F"," '{x+=$7}END{print x}' ./$CSV_FILE_SORTED)
        TOTAL_TIER3=$(awk -F"," '{x+=$8}END{print x}' ./$CSV_FILE_SORTED)

        echo "Total Instances: $TOTAL_INSTANCES,Total Processors: $TOTAL_PROCESSORS,Total Memory: $TOTAL_MEMORY,Total TIER1: $TOTAL_TIER1,Total TIER3: $TOTAL_TIER3,******,******,******" >> $CSV_FILE_SORTED

        MEMORY_PERCENTAGE_USAGE=$(echo "scale=2; 100*$TOTAL_MEMORY/$VIRTUAL_LIMIT_MEMORY" | bc -l)

        CORE_PERCENTAGE_USAGE=$(echo "scale=2; 100*$TOTAL_PROCESSORS/$VIRTUAL_LIMIT_CORE" | bc -l)

        # Adds content to the summary by team/group
        echo "$TEAM,$TOTAL_INSTANCES,$TOTAL_PROCESSORS,$TOTAL_MEMORY,$TOTAL_TIER1,$TOTAL_TIER3,$MEMORY_PERCENTAGE_USAGE%/$CORE_PERCENTAGE_USAGE%" >> $SUMMARY

        if [[ "$*" == *--pretty* ]]; then
            echo "*************************************************************"
            echo $TEAM
            cat ./$TEAM-sorted.csv
            printf '%s\n'
        fi

        rm -f ./$TEAM.csv
        rm -f ./$TEAM-sorted.csv
    done < "$ALLOCATION_FILE"

    sort -t "," --key 4 --numeric-sort ./$SUMMARY | grep -v '^null' >> ./$SUMMARY_SORTED

    # Sets the header for the summary csv file
    echo "Team/Group,Total VMs,Total Processors,Total Memory,Total Tier 1,Total Tier 3, % of memory used/% of cores used\n$(cat ./$SUMMARY_SORTED)" > ./$SUMMARY_SORTED

    TOTAL_INSTANCES_SUMMARY=$(awk -F"," '{x+=$2}END{print x}' ./$SUMMARY_SORTED)
    TOTAL_PROCESSORS_SUMMARY=$(awk -F"," '{x+=$3}END{print x}' ./$SUMMARY_SORTED)
    TOTAL_MEMORY_SUMMARY=$(awk -F"," '{x+=$4}END{print x}' ./$SUMMARY_SORTED)
    TOTAL_TIER1_SUMMARY=$(awk -F"," '{x+=$5}END{print x}' ./$SUMMARY_SORTED)
    TOTAL_TIER3_SUMMARY=$(awk -F"," '{x+=$6}END{print x}' ./$SUMMARY_SORTED)

    echo "TOTAL,$TOTAL_INSTANCES_SUMMARY,$TOTAL_PROCESSORS_SUMMARY,$TOTAL_MEMORY_SUMMARY,$TOTAL_TIER1_SUMMARY,$TOTAL_TIER3_SUMMARY,******" >> $SUMMARY_SORTED
    echo "******,******,******,******,******,******,******" >> $SUMMARY_SORTED
    echo "Virtual Memory Limit: $VIRTUAL_LIMIT_MEMORY G, Virtual Core Limit: $VIRTUAL_LIMIT_CORE cores" >> $SUMMARY_SORTED 

    if [[ "$*" == *--pretty* ]]; then
        echo  "**************************************************************"
        echo "Summary by Team/Group"
        cat ./$SUMMARY_SORTED
    fi
}

function run() {
    check_dependencies
    process $1 $2 "$@"
}

### Main Execution ###
ALLOCATION_FILE="$1"
POWERVS_SORTED_DATA="$2"

# Check if key vars are empty:
if [ $# -eq 0 ]
  then
    echo "Please, set the correct parameters to run this script."
    exit
fi
if [ -z "$ALLOCATION_FILE" ]; then
    echo "Please set ALLOCATION_FILE."
    exit
fi
if [ -z "$POWERVS_SORTED_DATA" ]; then
    echo "Please set POWERVS_SORTED_DATA."
    exit
fi

run "$@"
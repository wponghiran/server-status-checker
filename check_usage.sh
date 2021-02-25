#!/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print machine utilization
printf "${CYAN}MEM Usage: ${NC}"
free -m | awk 'NR==2{printf "%.2f%% of %s MB\n",$3*100/$2, $2 }'
printf "${GREEN}CPU Usage: ${NC}"
echo "$(ps -A -o pcpu | tail -n+2 | paste -sd+ | bc)% of $(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l) processors"

# check nvidia-smi exist (i.e. hash is not empty)
if type nvidia-smi &> /dev/null; then
    NVIDIA_SMI_OUTPUT=$(timeout 2 nvidia-smi)
    # timeout 2 nvidia-smi &>/dev/null
    RETURN_CODE=$?
    # exit if nvidia-smi takes too long
    if [[ $RETURN_CODE -eq 124 ]]; then
        printf "${RED} \_ GPU Usage:${NC} nvidia-smi doesn't respond in 2 seconds. Please check for error.\n"
        exit 1
    elif [[ $RETURN_CODE -eq 15 ]]; then
        printf "${RED} \_ GPU Usage:${NC} nvidia-smi quits prematurely. Please check for error.\n"
        exit 1
    else
        # get a report from nvidia-smi & gpu utilization
        NVIDIA_QUERY_OUTPUT=$(nvidia-smi -q --display=UTILIZATION,MEMORY)
        GPU_UTIL=($(echo "${NVIDIA_QUERY_OUTPUT}" | grep 'Gpu' | awk '{print $3}'))
        TEMP=$(echo "${NVIDIA_QUERY_OUTPUT}" | grep -A2 'FB Memory Usage')
        GPU_TOTAL_MEM=($(echo "${TEMP}" | grep 'Total' | awk '{print $3}'))
        GPU_USED_MEM=($(echo "${TEMP}" | grep 'Used' | awk '{print $3}'))
        NUM_GPU=${#GPU_TOTAL_MEM[@]}
        # for each gpu, print gpu utilization along with process owner on that gpu if possible 
        for ((GPU_ID=0;GPU_ID<${NUM_GPU};GPU_ID++)); do
            # NVIDIA_SMI_VERSION=$(modinfo nvidia | grep "^version:" | awk '{print $2}')
            NVIDIA_SMI_VERSION=$(echo "${NVIDIA_QUERY_OUTPUT}" | awk '$1 == "Driver" && $2 == "Version" {print $4}')
            # This should work with NVIDIA_SMI_VERSION > 450.51.06
            if [[ $NVIDIA_SMI_VERSION = "418.87.01" ]]; then
                PIDs=$(echo "${NVIDIA_SMI_OUTPUT}" | awk '$2 == "GPU" && $3 == "PID" {flag = 1} flag && $3 > 0 {print $2, $3}' | awk -v GPU_ID=$GPU_ID '$1 == GPU_ID {print $2}')
            else
                PIDs=$(echo "${NVIDIA_SMI_OUTPUT}" | awk '$2 == "GPU" && $5 == "PID" {flag = 1} flag && $5 > 0 {print $2, $5}' | awk -v GPU_ID=$GPU_ID '$1 == GPU_ID {print $2}')
            fi
            if [[ -z $PIDs ]]; then
                printf "${RED} \_ GPU#%s Usage:${NC} %3s%% (%5s of %5s MB) - ${CYAN}Free${NC}\n" ${GPU_ID} ${GPU_UTIL[GPU_ID]} ${GPU_USED_MEM[GPU_ID]} ${GPU_TOTAL_MEM[GPU_ID]}
            else
                USERS=""
                for PID in $PIDs; do
                    USERS="${USERS} $(ps -u --no-headers -p ${PID} | grep -o "^\S*")"
                done
                USERS=$(echo $USERS | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
                printf "${RED} \_ GPU#%s Usage:${NC} %3s%% (%5s of %5s MB) - ${USERS}\n" ${GPU_ID} ${GPU_UTIL[GPU_ID]} ${GPU_USED_MEM[GPU_ID]} ${GPU_TOTAL_MEM[GPU_ID]}
            fi
        done
    fi
fi


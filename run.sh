#!/bin/bash

# Transfer bash file
transfer_file='/home/eidf151/eidf151/username/code/code_deceptive_diffusion/transfer.sh'

# Update files
sh $transfer_file

# Namespace
namespace='eidf151ns'

# File number
if [ "$1" = "0" ]; then
  echo "Running file 0_example.py"
elif [ "$1" = "test0" ]; then
  echo "Running file test/0_analyzeAttackedSetUntargeted.py"
else
  echo "Invalid file number"
  exit 1
fi

# Run yml file
run_file="/home/eidf151/eidf151/username/code/code_deceptive_diffusion/yml/run_$1.yml"

# Create run job
kubectl -n $namespace apply -f $run_file

# Get run job name
job_name='lb-deceptive-diffusion-job'

# Get the pod name of the pod attached to the run job
pod_name=$(kubectl -n $namespace get pod -l job-name=$job_name -o jsonpath="{.items[0].metadata.name}")

# Wait for the run job to start
kubectl -n $namespace wait --for=condition=Ready pod/$pod_name --timeout=180s

# Get the logs of the run job
kubectl -n $namespace attach pod $pod_name

# Delete the run job
kubectl -n $namespace delete -f $run_file

# For certain jobs, retrieve results
if [ "$1" = "test2" ]; then
  sh /home/eidf151/eidf151/username/code/code_deceptive_diffusion/retrieve.sh results/
fi

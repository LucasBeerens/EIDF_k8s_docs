#!/bin/bash

# Namespace
namespace='eidf151ns'
# Get run job name
job_name='lb-deceptive-diffusion-job'

# Get the pod name of the pod attached to the run job
pod_name=$(kubectl -n $namespace get pod -l job-name=$job_name -o jsonpath="{.items[0].metadata.name}")

# Execute nvidia-smi command
kubectl -n $namespace exec -it $pod_name -- nvidia-smi
#!/bin/bash


# Step function in 5% increments for CPU utilization


while [ 1 ]; do
  for i in `seq 5 5 100`; do
    echo "$(date -u) Starting CPU throttle for 5 minutes @ ${i}%"
    stress-ng --cpu -1 --cpu-method all -t ${timeout} --cpu-load $i --metrics-brief
    echo "$(date -u) Done CPU throttle for 5 minutes @ ${i}%"
    sleep $(shuf -i 5-60 -n 1)
  done
done



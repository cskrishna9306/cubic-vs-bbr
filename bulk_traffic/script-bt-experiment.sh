#!/bin/bash
# This script in conjunction with script-bt-results.sh can be used to perform all the experiments for the project. 
# Replace the SERVER_IP and CLIENT_PORT with the actual values before execution
# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please provide an argument."
    exit 1
fi
# Access the first argument
CCA=$1
# Initialize the experimental period
TIME=100
# Print the argument
echo "Running experiments for the $CCA CCA ..."
# Initialize the TCP CCA
sudo sysctl -w net.ipv4.tcp_congestion_control=$CCA
# Initialize the write and receive buffers to be 1.9GB
sudo sysctl -w net.core.wmem_max=2040109465
sudo sysctl -w net.core.rmem_max=2040109465
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 2040109465"
sudo sysctl -w net.ipv4.tcp_wmem="4096 87380 2040109465"
# Experiment 0: Gather iperf data when there is no delay
echo "Running experiment 0 w/o any delay ..."
sudo tc qdisc del dev enp39s0 root
./script-bt-results.sh "$CCA-0ms-delay.txt" & iperf3 -c SERVER_IP -t $TIME -i 0.1 --cport CLIENT_PORT & wait
sleep 30
# Experiment 1a: Gather iperf data for this CCA w/ a delay of 20ms
echo "Running experiment 1a w/ delay 20ms ..."
sudo tc qdisc replace dev enp39s0 root netem delay 20ms
./script-bt-results.sh "$CCA-20ms-delay.txt" & iperf3 -c SERVER_IP -t $TIME -i 0.1 --cport CLIENT_PORT & wait
sleep 30
# Experiment 1b: Gather iperf data for this CCA w/ a delay of 50ms
echo "Running experiment 1b w/ delay 50ms ..."
sudo tc qdisc replace dev enp39s0 root netem delay 50ms
./script-bt-results.sh "$CCA-50ms-delay.txt" & iperf3 -c SERVER_IP -t $TIME -i 0.1 --cport CLIENT_PORT & wait
sleep 30
# Experiment 2a: Gather iperf data for this CCA w/ a delay of 20ms and packet loss of 0.005%
echo "Running experiment 2a w/ delay 20ms and packet loss 0.005% ..."
sudo tc qdisc replace dev enp39s0 root netem delay 20ms loss 0.005%
./script-bt-results.sh "$CCA-20ms-delay-0.005-loss.txt" & iperf3 -c SERVER_IP -t $TIME -i 0.1 --cport CLIENT_PORT & wait
sleep 30
# Experiment 2a: Gather iperf data for this CCA w/ a delay of 20ms and packet loss of 0.005%
echo "Running experiment 2b w/ delay 20ms and packet loss 0.01% ..."
sudo tc qdisc replace dev enp39s0 root netem delay 20ms loss 0.01%
./script-bt-results.sh "$CCA-20ms-delay-0.01-loss.txt" & iperf3 -c SERVER_IP -t $TIME -i 0.1 --cport CLIENT_PORT & wait
echo "Finished running experiments."
exit 0

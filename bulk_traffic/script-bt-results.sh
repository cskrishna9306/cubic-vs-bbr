#!/bin/bash
# This script is internally run by the parent script, script-bt-experiment.sh, to log the network metrics
# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please provide an argument."
    exit 1
fi

# Define server and client details
SERVER_PORT=""        # Replace with your server's port
CLIENT_IP=""  # Replace with your client's IP
OUTPUT_FILE=$1

# Output file for metric
echo "Tracking ss metrics..." 
echo "" > "$OUTPUT_FILE"

# Wait until the connection becomes active
echo "Waiting for the client connection..."
while true; do
    # Check if the connection is active
    ACTIVE_CONN=$(ss -tmi state established "( sport = :$SERVER_PORT )" | grep "$CLIENT_IP")

    if [ -n "$ACTIVE_CONN" ]; then
        echo "Connection detected. Starting to log metrics..."
        break
    fi

    # Wait for 1ms before checking again
    sleep 0.001
done

# Log metrics until the connection is closed
while true; do
    # Check if the connection is still active
    ACTIVE_CONN=$(ss -tmi state established "( sport = :$SERVER_PORT )" | grep "$CLIENT_IP" -A 1 | grep -o 'cwnd:[0-9]*\| mss:[0-9]*\| ssthresh:[0-9]*\|delivery_rate \S*\|rtt:\S*/\S*')

    if [ -z "$ACTIVE_CONN" ]; then
        echo "File transfer complete. Stopping tracking."
        break
    fi

    # Log the current ss metrics
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    echo "[$TIMESTAMP]" >> "$OUTPUT_FILE"
    echo "$ACTIVE_CONN" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # Wait for 0.01 seconds before the next iteration
    sleep 0.01
done

echo "Metrics logged to $OUTPUT_FILE"

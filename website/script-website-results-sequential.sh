#!/bin/bash
# Runs the data collection sequentially for each file download 
# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please provide an output file name."
    exit 1
fi

# Define server port
SERVER_PORT=""  # Replace with your server's port
CLIENT_IP=""  # Replace with your client's IP
OUTPUT_FILE=$1

# Define timeout duration (in seconds)
TIMEOUT=15

# Initialize the output file
echo "Tracking ss metrics..."
echo "" > "$OUTPUT_FILE"

# Initialize flow counter
FLOW_COUNT=0

while true; do
    echo "Waiting for a new connection..."
    START_TIME=$(date +%s)

    # Wait for a connection to become active, with timeout
    while true; do
        # Check if a connection is active
        ACTIVE_CONN=$(ss -tmi state established "( sport = :$SERVER_PORT )" | grep "$CLIENT_IP")

        if [ -n "$ACTIVE_CONN" ]; then
            FLOW_COUNT=$((FLOW_COUNT + 1))
            echo "Connection detected for Flow $FLOW_COUNT. Logging metrics..." | tee -a "$OUTPUT_FILE"
            echo "Start of Flow $FLOW_COUNT" >> "$OUTPUT_FILE"
            echo "----------------------------------------" >> "$OUTPUT_FILE"
            break
        fi

        # Check if the timeout has elapsed
        CURRENT_TIME=$(date +%s)
        if (( CURRENT_TIME - START_TIME >= TIMEOUT )); then
            echo "No connection detected within $TIMEOUT seconds. Exiting." | tee -a "$OUTPUT_FILE"
            exit 0
        fi

        # Wait for 1ms before checking again
        sleep 0.001
    done

    # Log metrics for the active connection
    while true; do
        # Check if the connection is still active
        ACTIVE_CONN=$(ss -tmi state established "( sport = :$SERVER_PORT )" | grep "$CLIENT_IP" -A 1 | grep -o 'cwnd:[0-9]*\| mss:[0-9]*\| ssthresh:[0-9]*\|delivery_rate \S*\|rtt:\S*/\S*')

        if [ -z "$ACTIVE_CONN" ]; then
            echo "Connection for Flow $FLOW_COUNT closed. Waiting for the next flow..." | tee -a "$OUTPUT_FILE"
            echo "End of Flow $FLOW_COUNT" >> "$OUTPUT_FILE"
            echo "----------------------------------------" >> "$OUTPUT_FILE"
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
done


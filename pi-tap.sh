#!/bin/bash

# Program: Tap 
# Author: gh0st_D3V
# Version: 3.1

# Set up a trap to handle the SIGINT signal
trap 'echo "Exiting script..."; exit' SIGINT

# Initialize variables
status="stopped"
capture_duration=3600

# Function to display menu options
display_menu() {
    echo "1. Start packet capture"
    echo "2. Stop packet capture"
    echo "3. Set capture duration (default is 1 hour)"
    echo "4. Exit script"
}

# Function to start packet capture
start_capture() {
    status="running"
    while :
    do
        # Check the available space on the hard drive
        available_space=$(df -h / | awk '{print $5}' | tail -n 1 | cut -d '%' -f 1)
        echo "Available disk space: $available_space%"

        # If the available space is less than 10%
        if [ $available_space -le 10 ]
        then
            # Remove the oldest .pcap file
            oldest_file=$(ls -t /home/gh0st/Documents/pi-taps/*.pcap | tail -n 1)
            rm -f $oldest_file
        fi

        # Get the current month, day, hour, and minute in the format MM-DD_HH:MM
        datetime=$(date +"%m-%d_%H:%M")

        # Start tcpdump and save output to a file with the current month, day, hour, and minute as the name
        echo "Capturing packets for $capture_duration seconds to pi-tap-$datetime.pcap..."
        tcpdump -i br0 -w /home/gh0st/Documents/pi-taps/pi-tap-$datetime.pcap &

        # Sleep for the specified duration
        sleep $capture_duration

        # Kill the tcpdump process
        kill $!

        # Check if the script has been stopped
        if [ $status == "stopped" ]
        then
            break
        fi
    done
}

# Function to stop packet capture
stop_capture() {
    status="stopped"
    echo "Packet capture stopped."
}

# Function to handle menu selections
while :
do
    display_menu
    read -p "Enter your selection: " selection

    case $selection in
        1) start_capture;;
        2) stop_capture;;
        3) read -p "Enter capture duration in seconds (default is 3600): " capture_duration;;
        4) exit;;
        *) echo "Invalid selection.";;
    esac
done

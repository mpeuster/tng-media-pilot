#!/bin/sh

source variables.env

mkdir -p /output/ffprobe/${HOSTNAME}

# Start the ffmpeg process:
timeout -t 90 ffprobe -show_frames -select_streams v -print_format json -i "rtmp://${STREAMING_ENGINE}:1935/plane/${STREAM}" > /output/ffprobe/${HOSTNAME}/logs.txt &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ffprobe: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 1; do
  ps aux | grep ffprobe | grep -q -v grep
  PROCESS_1_STATUS=$?
  if [ $PROCESS_1_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 0
  fi
done

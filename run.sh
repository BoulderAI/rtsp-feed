#!/bin/sh

if [ -z "$FILE_PATH" ]; then 
  echo "'FILE_PATH' is not set. Please set FILE_PATH."; 
  exit 1
else 
  echo "'FILE_PATH' is set to '$FILE_PATH'"; 
fi

if [ -z "$STREAM_ENDPOINT" ]; then 
  echo "'STREAM_ENDPOINT' is not set. Please set STREAM_ENDPOINT."; 
  exit 1
else 
  echo "'STREAM_ENDPOINT' is set to '$STREAM_ENDPOINT'"; 
fi

if [ -z "$PORT" ]; then
  PORT=8554
  echo "'PORT' is not set, defaulting to ${PORT}"
fi


echo "${FILE_PATH}" | grep "^gs"
if [ $? -eq 0 ]; then
  echo "Handling Google Storage Protocol..."
  gsutil cp -r $FILE_PATH /data/
  FILE_PATH=/data
else
  echo "Handling standard file type..."
fi

tmpfile=`mktemp`
find ${FILE_PATH} -type f | sed 's/^/file /g' | sed '1s/^/ffconcat version 1.0\n/' > $tmpfile
endpoint="rtsp://$(ip route get 8.8.8.8 | tr -s ' ' | cut -d' ' -f7):${PORT}/${STREAM_ENDPOINT}"
echo "Stream will be available at $endpoint"
echo "tmp file contents:"
cat ${tmpfile}
echo ffmpeg -re -fflags +genpts -stream_loop -1 -safe 0 -i $tmpfile -flush_packets 0 -c copy -f rtsp rtsp://rtsp_server:${PORT}/${STREAM_ENDPOINT}
ffmpeg -re -fflags +genpts -stream_loop -1 -safe 0 -i $tmpfile -flush_packets 0 -c copy -f rtsp rtsp://rtsp_server:${PORT}/${STREAM_ENDPOINT}

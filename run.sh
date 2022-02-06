#!/bin/sh

stream_file()
{
    filename=$1
    stream_endpoint=$2
    tmpfile=`mktemp`
    find ${filename} -type f | sed 's/^/file /g' | sed '1s/^/ffconcat version 1.0\n/' > $tmpfile
    endpoint="rtsp://$(ip route get 8.8.8.8 | tr -s ' ' | cut -d' ' -f7):${PORT}/${stream_endpoint}"
    echo "Stream will be available at $endpoint"
    echo "tmp file contents:"
    cat ${tmpfile}
    echo ffmpeg -re -fflags +genpts -stream_loop -1 -safe 0 -i $tmpfile -flush_packets 0 -c copy -f rtsp rtsp://rtsp_server:${PORT}/${stream_endpoint}
    set -e
    ffmpeg -re -fflags +genpts -stream_loop -1 -safe 0 -i $tmpfile -flush_packets 0 -c copy -f rtsp rtsp://rtsp_server:${PORT}/${stream_endpoint}
}

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

if [ -d ${FILE_PATH} ]; then
  echo "Reading content of directory at ${FILE_PATH}"
  for file in ${FILE_PATH}/*; do
    filename_no_extension=$(basename ${file} .mkv)
    stream_file ${file} ${STREAM_ENDPOINT}/${filename_no_extension} &
  done
  echo "All streams running"
  wait
else
  stream_file ${FILE_PATH} ${STREAM_ENDPOINT}
fi


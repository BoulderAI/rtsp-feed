#!/bin/bash
pushd $(dirname $0)
if [ $# -lt 2 ]; then
    echo "Usage $0 <stream endpoint> <path to source file>"
    exit 1
fi
source environment.sh
stream_endpoint=$1
file_path=$2
tmpdir=$(mktemp -d)
volmount=${tmpdir}:${tmpdir}
if [ -f ${file_path} -o -d ${file_path} ]; then
    file_path=$(realpath ${file_path})
    volmount="${file_path}:${file_path}"
    echo "Passing volume mount arg ${volmount} into the container"
fi
stream_endpoint_additional=""
if [ -d ${file_path} ]; then
    stream_endpoint_additional="/filename without .mkv extension"
fi
echo "Starting rtsp stream on endpoint ${stream_endpoint} using file(s) at ${file_path} and exporting on RTSP port ${RTSP_PORT}"
echo "Access with rtsp://$(ip route get 8.8.8.8 | tr -s ' ' | cut -d' ' -f7):${RTSP_PORT}/${stream_endpoint}${stream_endpoint_additional}"
cat << EOF > .env
RTSP_PORT=${RTSP_PORT}
FILE_PATH=${file_path}
VOLUME_MOUNT=${volmount}
STREAM_ENDPOINT=${stream_endpoint}
EOF
docker-compose up -d

#!/bin/bash
thisdir=$(dirname $0)
pushd ${thisdir}
source environment.sh
docker build . -t baicontainers/rtsp-feed

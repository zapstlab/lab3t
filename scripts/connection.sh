#!/bin/bash

set -e

url="http://${host_ip}:${port}"
ctx logger info "Server HTTP endpoint: ${url}"

response=$(
    curl $url \
        --write-out %{http_code} \
        --silent \
        --output /dev/null )

test "$response" -ge 200 && test "$response" -le 299

if [ $? -eq 0 ]; then
    ctx logger info "HTTP connection established"
	exit 0
else
	ctx logger error "HTTP connection failed"
    exit 1
fi

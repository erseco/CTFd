#!/usr/bin/env sh
apk --no-cache add curl
curl --silent --fail http://app:8000/setup | grep '<title>CTFd</title>'

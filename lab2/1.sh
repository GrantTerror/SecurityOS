#!/usr/bin/env bash

log=/tmp/run.log

if [[ -f "$log" ]]; then
    prev=$(wc -l < "$log")
else
    prev=0
fi

date '+%Y-%m-%d %H:%M:%S' >> "$log"
echo "Hello, World!"
echo "$prev" >&2

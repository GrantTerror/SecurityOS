#!/usr/bin/env bash
while IFS= read -r line; do
    if grep -qw 'bin' <<< "$line"; then
        echo "$line" >&2
    fi
done

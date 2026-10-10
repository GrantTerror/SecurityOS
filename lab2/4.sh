#!/usr/bin/env bash

shopt -s nullglob

files=("$HOME"/*.txt)

printf '%s\n' "${files[@]}"

total_bytes=$(wc -c "${files[@]}" | tail -n 1 | awk '{print $1}')
total_lines=$(wc -l "${files[@]}" | tail -n 1 | awk '{print $1}')

echo "Bytes: $total_bytes"
echo "Lines: $total_lines"

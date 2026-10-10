#!/usr/bin/env bash

if (( $# != 1 )); then
    exit 1
fi

csv="$1"
[[ -f "$csv" ]] || { echo "File not found: $csv" >&2; exit 1; }

awk -F, '
NR == 1 { next }
{
    gsub(/[[:space:]]/, "", $NF)
    if ($NF ~ /^-?[0-9]+(\.[0-9]+)?$/) 
    {
        sum += $NF
        count++
        if (count == 1 || $NF > max) max = $NF
    }
}
END {
    printf "Total: %.2f\n", sum
    printf "Average: %.2f\n", sum / count
    printf "Most expensive: %.2d\n", max
}' "$csv" | tee sales_report.txt


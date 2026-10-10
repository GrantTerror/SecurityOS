#!/usr/bin/env bash

even="even.txt"
odd="odd.txt"

processed=0

for num in "$@"; do
    
    ((processed++))

    if (( num % 3 == 0 )); then
        continue
    fi

    if ((num % 2 == 0 )); then
        echo "$num" >> "$even"
    else
        echo "$num" >> "$odd"
    fi

done

echo "Processed: $processed"


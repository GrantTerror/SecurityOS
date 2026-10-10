#!/usr/bin/env bash


find . -type f -print0 | xargs -0 -r md5sum | awk '
{
    hash = $1
    $1 = ""
    sub(/^ +/, "")
    file = $0
    files[hash] = files[hash] file "\n"
}
END {
    for (hash in files) {
        n = split(files[hash], a, "\n")
        if (a[n] == "") n--
        if (n>1) {
            for (i=1; i<=n; i++) {
                print n - 1, a[i]
            }
        }
    }
}'

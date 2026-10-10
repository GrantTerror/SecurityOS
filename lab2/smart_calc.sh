#!/usr/bin/env bash

usage() {
    cat <<'EOF'
Usage: smart_calc.sh [options] number1 number2
Options:
    -h Show this
    -v Verbose output
    -o <file> Output file specification
    -a Addition
    -m Multiplication
    -d Division
    -p Power
    -s Substraction
EOF
}

verbose=0
outfile=""
operation=""

while getopts ":hvo:amdps" opt; do
    case "$opt" in
        h) usage; exit 0;;
        v) verbose=1 ;;
        o) outfile="$OPTARG";;
        a) operation="add";;
        m) operation="mul";;
        d) operation="div";;
        p) operation="pow";;
        s) operation="sub";;
        \?) echo "Invalid Option" >&2; usage >&2;  exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if [[ -z "$operation" ]]; then
    echo "No opertaion" >&2
    exit 1
fi

if (( $# == 0 )); then
    usage >&2
    exit 1
fi

case "$operation" in
    add) result=$(awk 'BEGIN { sum=0; for (i=1; i<ARGC; i++) sum += ARGV[i]; print sum }' "$@");;
    mul) result=$(awk 'BEGIN { prod=1; for (i=1; i<ARGC; i++) prod *= ARGV[i]; print prod }' "$@");;
    div) result=$(awk 'BEGIN { if (ARGC < 3) { print "Need two numbers." > "/dev/stderr"; exit 1 } res=ARGV[1]; for (i=2; i<ARGC; i++) {if (ARGV[i] == 0) {print "Div by zero" > "/dev/stderr"; exit 1} res /= ARGV[i] } print res' "$@");;
    pow) result=$(awk 'BEGIN { if (ARGC != 3) { print "Need exactly two numbers." > "/dev/stderr"; exit 1 } print ARGV[1] ^ ARGV[2]}' "$@");;
    sub) result=$(awk 'BEGIN { if (ARGC < 3) { print "Need two numbers." > "/dev/stderr"; exit 1 } res=ARGV[1]; for (i=2; i<ARGC; i++) res-=ARGV[i]; print res }' "$@");;
esac

if ((verbose)); then
    echo "Operation: $operation" >&2
    echo "Numbers: $*" >&2
fi

if [[ -n "$outfile" ]]; then
    printf '%s\n' "$result" | tee "$outfile"
else
    printf '%s\n' "$result"
fi


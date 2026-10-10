#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: analyze_sales.sh [-f csv] [-g] sales.csv
Options:
  -f csv   Save report as CSV: sales_report.csv
  -g       Generate PostgreSQL import SQL from sales_report.csv
EOF
}

format="text"
generate_sql=0

while getopts ":f:gh" opt; do
    case "$opt" in
        f) format="$OPTARG" ;;
        g) generate_sql=1 ;;
        h) usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument" >&2; exit 1 ;;
    esac
done

shift $((OPTIND - 1))

if (( $# != 1 )); then
    usage >&2
    exit 1
fi

csv="$1"
[[ -f "$csv" ]] || { echo "File not found: $csv" >&2; exit 1; }

read -r total avg max < <(awk -F, '
NR == 1 { next }
{
    gsub(/[[:space:]]/, "", $NF)
    if ($NF ~ /^-?[0-9]+(\.[0-9]+)?$/) {
        sum += $NF
        count++
        if (count == 1 || $NF > max) max = $NF
    }
}
END {
    if (count == 0) {
        exit 1
    }
    printf "%.2f %.2f %.2f\n", sum, sum / count, max
}' "$csv")

if [[ "$format" == "csv" ]]; then
    report_file="sales_report.csv"
    {
        echo "metric,value"
        echo "total_sales,$total"
        echo "average_sale,$avg"
        echo "max_sale,$max"
    } | tee "$report_file"
else
    report_file="sales_report.txt"
    {
        echo "Total sales: $total"
        echo "Average sale: $avg"
        echo "Most expensive sale: $max"
    } | tee "$report_file"
fi

if (( generate_sql )); then
    if [[ ! -f sales_report.csv ]]; then
        {
            echo "metric,value"
            echo "total_sales,$total"
            echo "average_sale,$avg"
            echo "max_sale,$max"
        } > sales_report.csv
    fi

    sql_file="sales_report_import.sql"
    csv_abs=$(realpath sales_report.csv)

    cat > "$sql_file" <<EOF
CREATE TABLE IF NOT EXISTS sales_report (
    metric TEXT PRIMARY KEY,
    value NUMERIC
);

COPY sales_report(metric, value)
FROM '$csv_abs'
WITH (FORMAT csv, HEADER true);
EOF

    echo "SQL in $sql_file"
fi

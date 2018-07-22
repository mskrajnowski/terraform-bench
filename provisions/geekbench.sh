#!/bin/sh

set -e

version=4.2.3

echo "Downloading Geekbench $version"
cd /tmp
wget "http://cdn.geekbench.com/Geekbench-$version-Linux.tar.gz"

echo "Extracting"
tar -zxvf "Geekbench-$version-Linux.tar.gz"

cd "Geekbench-$version-Linux"
mkdir -p /var/log/geekbench

echo "Benchmarking"
./geekbench_x86_64 --cpu | tee /var/log/geekbench/cpu.log

echo "Gathering results"
url=$(
    cat /var/log/geekbench/cpu.log | 
    egrep -o 'https://browser.geekbench.com/v4/cpu/[0-9]+$'
)
scores=$(
    hxnormalize -x "$url" | 
    hxselect -c -s '\n' .summary td.score
)

single_core_score=$(echo "$scores" | head -n1)
multi_core_score=$(echo "$scores" | tail -n1)

jq -n \
    --arg url "$url" \
    --arg single "$single_core_score" \
    --arg multi "$multi_core_score" \
    '{"url": $url, "single": $single, "multi": $multi}' \
    >/var/log/geekbench/result.json

echo "Done"

#!/bin/bash
# Compile and run every testbench in tb/. Usage: ./run_all.sh [tb_name]
cd "$(dirname "$0")"
mkdir -p sim
pass=0; fail=0
if [ -n "$1" ]; then list="tb/$1.v"; else list=$(ls tb/tb_*.v); fi
for tb in $list; do
    name=$(basename "$tb" .v)
    echo "=== $name ==="
    if ! iverilog -g2005 -Wall -s "$name" -o "sim/$name.vvp" rtl/*.v "$tb"; then
        echo "COMPILE ERROR in $name"; fail=$((fail+1)); continue
    fi
    vvp "sim/$name.vvp" | tee "sim/$name.log"
    if grep -q "RESULT: PASS" "sim/$name.log"; then pass=$((pass+1)); else fail=$((fail+1)); fi
done
echo "-----------------------------"
echo "Passed: $pass   Failed: $fail"
[ "$fail" -eq 0 ]

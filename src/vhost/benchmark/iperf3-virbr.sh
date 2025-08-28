#/bin/bash
# Validate virtual bridge throughput
SERVER_ADDR="vnas.lan.tbk.fi"
TEST_DUR="30"
SEG_SIZE="9000"

iperf3 -c "$SERVER_ADDR" -t "$TEST_DUR" -M "$SEG_SIZE"

#!/bin/bash
echo "==============================="
echo "   NETWORK INFORMATION REPORT  "
echo "==============================="
echo ""
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date: $(date)"
echo ""
echo "--- IP Addresses ---"
ip addr show | grep inet
echo ""
echo "--- Routing Table ---"
netstat -r
echo ""
echo "--- Open Ports ---"
netstat -tulpn
echo ""
echo "--- DNS Server ---"
cat /etc/resolv.conf | grep nameserver
echo ""
echo "==============================="


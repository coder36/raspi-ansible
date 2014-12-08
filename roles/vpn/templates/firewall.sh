#!/bin/bash
iptables -t filter -F
iptables -t nat -F
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s "10.8.0.0/24" -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s "10.8.0.0/24" -j MASQUERADE

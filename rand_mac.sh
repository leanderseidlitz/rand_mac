#!/bin/bash

set -euo pipefail

print_usage() {
	echo "usage: $0 [-i interface] [-a]"
	exit 0
}

rand_mac() {
	# $(($[RANDOM%4]*4+$[RANDOM%2])): %4*4 for random nums between 0 and 16 that dont have the lowest two bits set (== max is 12)
	printf '%01x%01x:%02x:%02x:%02x:%02x:%02x\n' $[RANDOM%16] $(($[RANDOM%4]*4)) $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]
}

[[ "$UID" != 0 ]] && { echo "must be root"; exit 1; }

while getopts ":i:h" o; do
	case "$o" in
		i)
			INTERFACE="$OPTARG"
			;;
		x)
			set -x
			;;
		h|*)
			print_usage
			;;
	esac
done
shift $((OPTIND-1))

[[ -z "${INTERFACE:-}" ]] && print_usage

OPERSTATE="$(</sys/class/net/$INTERFACE/operstate)"

[[ "$OPERSTATE" == "up" ]] && { echo "interface $INTERFACE is up, cannot proceed"; exit 1; }

MAC="$(rand_mac)"
echo "$INTERFACE -> $MAC"
ip link set addr "$MAC" dev "$INTERFACE"

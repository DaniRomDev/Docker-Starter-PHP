#!/usr/bin/env bash
set -euo pipefail

#/ Adds or removes an entry from /etc/hosts. usage:
#/ 
#/    add a host:    ./manage-etc-hosts add <hostname> [ip]
#/ remove a host:    ./manage-etc-hosts remove <hostname>

usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
if [ "${1:-}" == "" ]; then usage; exit 1; fi

# Hostname to add/remove.
hostname="$2"

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

remove() {
    if [ -n "$(grep "[[:space:]]$hostname" /etc/hosts)" ]; then
        echo -n "$hostname found in /etc/hosts. ";
        try sudo sed -ie "/[[:space:]]$hostname/d" "/etc/hosts";
        echo "Removed.";
    else
        yell "$hostname was not found in /etc/hosts";
    fi
}

add() {
    if [ -n "$(grep "[[:space:]]$hostname" /etc/hosts)" ]; then
        yell "$hostname, already exists: $(grep $hostname /etc/hosts)";
    else
        ip="${2:-127.0.0.1}"
        try printf "%s\t%s\n" "$ip" "$hostname" | sudo tee -a "/etc/hosts" > /dev/null;

        if [ -n "$(grep $hostname /etc/hosts)" ]; then
            echo -n "$hostname was added succesfully: ";
            echo "$(grep $hostname /etc/hosts)";
        else
            die "Failed to add $hostname";
        fi
    fi
}

$@

#!/bin/bash

die() {
	echo >&2 "$@"
	exit 1
}

[ "$#" -eq 1 ] || die "usage: ${0} <location>"

ssh-keygen -t rsa -f "${1}"

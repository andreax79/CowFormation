#!/usr/bin/env bash

cd "$(dirname "$0")" || exit
source ./lib/mo.sh
source ./lib/cow_formation.sh

cow_formation "$@"

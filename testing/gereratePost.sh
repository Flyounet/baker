#!/bin/bash

_path="$( cd "$(dirname "${0}")"; pwd )"

readarray -t posts < <(find "${_path}" -name '*.md' | sort -r)

[[ "${1:-}" =~ ^[0-9]+$ ]] || usage

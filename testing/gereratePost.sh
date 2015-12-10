#!/bin/bash

die() {
	echo "${@}" >&2
	exit 1
}

usage() {
	cat <<-POUET
${0} <number of post>
POUET
	exit 1
}



[[ "${1:-}" =~ ^[0-9]+$ ]] || usage

_path="$( cd "$(dirname "${0}")"; pwd )"
readarray -t posts < <(find "${_path}" -name '*.md')
nbpost=${#posts[@]}
readarray -t cats < <(for i in {1..5}; do echo "cat_${i}"; done)

# pseudo initialisation
for ((i=0;i<$RANDOM;i++)); do
	n=$RANDOM
done
# Some cleaning
cd "${_path}" && rm -rf "./posts" && mkdir "./posts"
cd "${_path}" && rm -rf "./draft" && mkdir "./draft"
uts="$(date '+%s')"
echo "[Info] Nb Posts : ${nbpost} - Nb Tags : ${#cats[@]} - Nb posts to generate : ${1}"
all=0
while [ ${nbpub:=0} -le ${1} ]; do
	# pickup a post
	f="$( basename "${posts[$((RANDOM%${nbpost}))]}" )"
	if [[ "${f}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-.*$ ]]; then
		echo "file dated"
	fi
	echo $f
	(( nbpub++ ))
done
echo $(( RANDOM%${#cats[@]} ))

echo ${#cats[@]}

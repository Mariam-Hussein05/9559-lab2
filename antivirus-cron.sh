#!/bin/bash
# Usage: ./antivirus-cron.sh dir malicious_dir
# One scan pass per run. Cron provides the repetition instead of a loop with sleep.

#=====THIS SCRIPT AND restore.sh MUST NOT RUN AT THE SAME TIME=====#
exec 9> /tmp/antivirus.lock
flock -n 9 || { echo "restore.sh or antivirusd.sh is already running."; exit 1; }

cd "$(dirname "$0")"
#=====KEYWORDS THAT DETECT A MALICIOUS FILE=====#
flagged_extension=(".exe" ".bat" ".vbs" ".scr" ".ps1")
flagged_content=("virus" "trojan" "malware" "worm" "ransomware")

dir="$1"
malicious_dir="$2"

check_malicious(){
    for i in "${flagged_extension[@]}"; do
        [[ $1 == *"$i" ]] && return 0
    done
    for j in "${flagged_content[@]}"; do
        grep -qi "$j" "$1" && return 0
    done
    return 1
}

scan(){
    for f in "$dir"/*; do
        if check_malicious "$f"; then
            name=$(basename "$f")
            echo "$name is malicious and it is DELETED"
            mv "$f" "$malicious_dir/$name"
        fi
    done
}

if [ ! -f directory-info.last ]; then
    scan
    ls -l "$dir" > directory-info.last
else
    ls -l "$dir" > directory-info.new
    if ! cmp -s directory-info.last directory-info.new; then
        scan
        cp directory-info.new directory-info.last
    fi
fi

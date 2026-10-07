#!/bin/bash
# Usage: ./restore.sh dir malicious_dir

#anitivirusd.sh and restore.sh can't run simultaneously
exec 9> /tmp/antivirus.lock
flock -n 9 || { echo "antivirusd.sh is already running. Stop it first."; exit 1; }

dir="$1"
malicious_dir="$2"

if [ -z "$(ls -A "$malicious_dir")" ]; then
    echo "No malicious files to review."
    exit 0
fi

while [ -n "$(ls -A "$malicious_dir")" ]; do
    echo "The following files are in $malicious_dir:"
    files=("$malicious_dir"/*)
    for i in "${!files[@]}"; do
        echo "$((i + 1)). $(basename "${files[$i]}")"
    done
    read -p "Pick a file number: " pick
    name=$(basename "${files[$((pick - 1))]}")
    echo "1-Restore this file back into $dir (it was a false positive) "
    echo "2-Permanently delete this file from $malicious_dir (it was genuinely malicious) "
    echo "3-Leave this file as-is and go back to the list "
    read -p "Choice: " choice
    if [ "$choice" == "1" ]
    then
        mv "$malicious_dir/$name" "$dir"
        
        echo "Restored $name to $dir"
    elif [ "$choice" == "2"]
    then
        rm "$malicious_dir/$name"
        echo "$name permanently deleted"
    else
        echo "$name left as-is in $malicious_dir"
    fi
done
#!/bin/bash
# Usage: ./antivirusd.sh dir malicious_dir interval-secs

#=====KEYWOARDS THAT DETECT A MALICIOUS FILE=====#
flagged_extension=(".exe" ".bat"  ".vbs" ".scr" ".ps1")
flagged_content=("virus" "trojan" "malware" "worm" "ransomware")

dir="$1"
malicious_dir="$2"
interval_secs="$3"

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
            name=$(basename "$f") #here it cuts everthing before the last / and returns the name of the file
            echo "$name is malicious and it is DELETED"
            mv "$f" "$malicious_dir/$name"
        fi
    done
}

if [ ! -f directory-info.last ]; then
    scan
    ls -l "$dir" > directory-info.last
fi


while true; do
    sleep "$interval_secs"
    ls -l "$dir" > directory-info.new
    if ! cmp -s directory-info.last directory-info.new; then
        scan
        cp directory-info.new directory-info.last
    fi
done

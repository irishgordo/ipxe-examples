#!/bin/bash

server="tftp://$2"

while IFS= read -r path; do
    [[ "$path" =~ ^\ *$ ]] && continue
    dir="$(dirname "$path")"
    printf "GET %s => %s\n" "$path" "$dir"
    ! [ -d "$dir" ] && mkdir -p "$dir"
    curl -o "$path" "$server/$path"
done < "$1"

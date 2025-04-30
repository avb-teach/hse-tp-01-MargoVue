#!/bin/bash

depth=""
input="$1"
output="$2"
useless="$3"
maximal_depth="$4"

if [[ $useless == "" ]]; then
    mkdir -p "$output"

    if [[ -n "$depth" ]]; then
        files=$(find "$input" -maxdepth "$depth" -type f)
    else
        files=$(find "$input" -type f)
    fi


    for file in $files; do
        name=$(basename "$file")
        path="$output/$name"

        if [[ -e "$path" ]]; then
            base="${name%.*}"
            ext="${name##*.}"
            n=1
            while [[ -e "$output/${base}${n}.${ext}" ]]; do
                n=$((n+1))
            done
            path="$output/${base}${n}.${ext}"
        fi

        cp "$file" "$path"
    done
fi

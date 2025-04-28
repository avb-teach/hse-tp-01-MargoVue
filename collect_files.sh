#!/bin/bash

input="$1"
output="$2"
depth=""

if [[ "$3" == "--max_depth" && -n "$4" ]]; then
    depth="$4"
fi

if [[ -z "$input" || -z "$output" ]]; then
    echo "Нужно указать директории!"
    exit 1
fi

input="${input%/}"

mkdir -p "$output"

if [[ -n "$depth" ]]; then
    files=$(find "$input" -maxdepth "$depth" -type f)
else
    files=$(find "$input" -type f)
fi

for file in $files; do
    rel_path="${file#$input/}"
    rel_path="${rel_path#/}"
    
    dest_path="$output/$rel_path"
    dest_dir=$(dirname "$dest_path")
    
    mkdir -p "$dest_dir"
    
    cp "$file" "$dest_path"
done
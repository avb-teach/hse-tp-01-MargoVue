#!/bin/bash

if [[ "$1" == "--max_depth" ]]; then
    depth="$2"
    input="$3"
    output="$4"
else
    depth=""
    input="$1"
    output="$2"
fi

if [[ -z "$input" || -z "$output" ]]; then
    echo "Нужно указать директории!"
    echo "Использование: $0 [--max_depth N] input_dir output_dir"
    exit 1
fi

mkdir -p "$input"/{dir2,dir3}
touch "$input"/a.txt "$input"/dir2/b.txt "$input"/dir3/c.txt

mkdir -p "$output"
rm -rf "$output"/*

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


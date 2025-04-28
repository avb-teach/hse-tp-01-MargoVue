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
    exit 1
fi

mkdir -p "$output"

if [[ -n "$depth" ]]; then
    files=$(find "$input" -maxdepth "$depth" -type f)
else
    files=$(find "$input" -type f)
fi

for file in $files; do
    rel_path="${file#$input/}"
    path="$output/$rel_path"

    mkdir -p "$(dirname "$path")"

    cp "$file" "$path"
done

# Удаляем пустые папки
find "$output" -type d -empty -delete
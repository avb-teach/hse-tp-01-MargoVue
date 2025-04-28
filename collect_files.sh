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

find "$input" -type f | while read -r file; do
    rel_path="${file#$input/}"
    rel_path="${rel_path#/}"
    
    # Вычисляем глубину файла
    slashes="${rel_path//[^\/]/}"
    current_depth=$((${#slashes} + 1))
    
    if [[ -n "$depth" && $current_depth -gt $depth ]]; then
        # Для файлов глубже максимальной глубины
        IFS='/' read -ra parts <<< "$rel_path"

        new_rel_path="depth3"
        for ((i=$depth; i<${#parts[@]}; i++)); do
            new_rel_path+="/${parts[i]}"
        done
    else
        new_rel_path="$rel_path"
    fi
    
    dest_path="$output/$new_rel_path"
    dest_dir=$(dirname "$dest_path")
    
    mkdir -p "$dest_dir"
    cp "$file" "$dest_path"
done
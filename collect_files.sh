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

if [[ -z "$input"  -z "$output" ]]; then
    echo "Нужно указать директории!"
    exit 1
fi

mkdir -p "$output"

remove_empty_dirs() {
    find "$output" -type d -empty -delete
}

if [[ -z "$depth"  "$depth" -eq 1 ]]; then
    files=$(find "$input" -maxdepth 1 -type f)
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
    exit 0
fi

cp -r "$input/"* "$output/"

while true; do
    max_level=$(find "$output" -type d | awk -F/ '{print NF}' | sort -nr | head -n1)
    base_level=$(echo "$output" | awk -F/ '{print NF}')
    current_depth=$((max_level - base_level))

    if [[ "$current_depth" -lt "$depth" ]]; then
        break
    fi

    deep_dirs=$(find "$output" -type d -mindepth 1 -maxdepth 100 | awk -v base="$base_level" -F/ '{if (NF-base == '"$depth"') print $0}')

    if [[ -z "$deep_dirs" ]]; then
        break
    fi

    for dir in $deep_dirs; do
        rel_path=${dir#"$output/"}
        parents_to_lift=$((depth-2))
        new_base=""

        IFS='/' read -ra parts <<< "$rel_path"
        len=${#parts[@]}

        if (( parents_to_lift >= 0 && len > parents_to_lift )); then
            for ((i=0; i<=parents_to_lift; i++)); do
                new_base="$new_base${parts[i]}/"
            done
        fi

        mkdir -p "$output/$new_base${parts[parents_to_lift+1]}"

        find "$dir" -maxdepth 1 -type f | while read -r file; do
            cp "$file" "$output/$new_base${parts[parents_to_lift+1]}/"
        done

        rm -r "$dir"
    done

    remove_empty_dirs
done
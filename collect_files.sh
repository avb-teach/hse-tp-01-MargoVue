#!/bin/bash

if [[ "$1" == "--max_depth" ]]; then
    depth="$2"
    indir="$3"
    outdir="$4"
else
    depth=""
    indir="$1"
    outdir="$2"
fi

if [[ -z "$indir"  -z "$outdir" ]]; then
    echo "Укажи директории!"
    exit 1
fi

mkdir -p "$outdir"

clear_empty() {
    find "$outdir" -type d -empty -delete
}

if [[ -z "$depth"  "$depth" -eq 1 ]]; then
    for file in "$indir"/*; do
        if [[ -f "$file" ]]; then
            name=$(basename "$file")
            if [[ -e "$outdir/$name" ]]; then
                n=1
                base="${name%.*}"
                ext="${name##*.}"
                while [[ -e "$outdir/${base}${n}.${ext}" ]]; do
                    n=$((n+1))
                done
                name="${base}${n}.${ext}"
            fi
            cp "$file" "$outdir/$name"
        fi
    done
    exit
fi

cp -r "$indir"/* "$outdir/"

while true; do
    maxd=$(find "$outdir" -type d | awk -F/ '{print NF}' | sort -nr | head -n1)
    based=$(echo "$outdir" | awk -F/ '{print NF}')
    nowd=$((maxd - based))

    if [[ "$nowd" -lt "$depth" ]]; then
        break
    fi

    folders=$(find "$outdir" -type d | awk -v b="$based" -F/ '{if (NF-b == '"$depth"') print $0}')

    if [[ -z "$folders" ]]; then
        break
    fi

    for d in $folders; do
        p=${d#"$outdir/"}
        lift=$((depth-2))
        path=""

        IFS="/" read -ra arr <<< "$p"
        len=${#arr[@]}

        if (( lift >= 0 && len > lift )); then
            for ((i=0;i<=lift;i++)); do
                path="$path${arr[i]}/"
            done
        fi

        mkdir -p "$outdir/$path${arr[lift+1]}"

        for f in "$d"/*; do
            if [[ -f "$f" ]]; then
                cp "$f" "$outdir/$path${arr[lift+1]}/"
            fi
        done

        rm -r "$d"
    done

    clear_empty
done
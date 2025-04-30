#!/bin/bash
depth=""
input="$1"
output="$2"
useless="$3"
maximal_depth="$4"



if [[ $useless == "" || $maximal_depth == "1" ]]; then
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
else
    cp -r $input/* $output/
    find $output -type d -empty > empty_folders.txt
    while [ "$(cat empty_folders.txt)" != "" ]; do
        find $output -type d -empty -exec rmdir {} +
        find $output -type d -empty > empty_folders.txt
    done
    find $output -maxdepth $(($maximal_depth-1)) -type d -print > box.txt
    find $output -maxdepth $maximal_depth -type d -print > second_box.txt
    sed -i 1d box.txt 
    sed -i 1d second_box.txt 

    cat second_box.txt box.txt box.txt | sort | uniq --unique > third_box.txt 

    l=$output
    echo $l > outdir_end.txt
    outdir_end=$(grep -E '' outdir_end.txt | rev | cut -d'/' -f1 | rev)
    counter=0
    while [ "$l" != "$outdir_end" ]
    do
    l=$(echo ${l#*/})
    counter=$(($counter+1))
    done
    standard_depth=$counter
    


    if [ "$(($maximal_depth-2))" -gt "0" ]; then
        while [ "$(cat third_box.txt)" != "" ]; do  
            for cur_path_to_folder in $(cat third_box.txt)
            do
            s=$cur_path_to_folder

            for (( i=0; i < $(($standard_depth+$(($maximal_depth-2))+1)); i++ ))
            do
            s=$(echo ${s#*/})
            done

            mkdir -p $output/$s
            cp -r $cur_path_to_folder/* $output/$s/
            rm -r $cur_path_to_folder
            done
            
            find $output -type d -empty > empty_folders.txt
            while [ "$(cat empty_folders.txt)" != "" ]; do
                find $output -type d -empty -exec rmdir {} +
                find $output -type d -empty > empty_folders.txt
            done
            find $output -maxdepth $(($maximal_depth-1)) -type d -print > box.txt
            find $output -maxdepth $maximal_depth -type d -print > second_box.txt
            sed -i 1d box.txt 
            sed -i 1d second_box.txt

            cat second_box.txt box.txt box.txt | sort | uniq --unique > third_box.txt
        done
    else
        while [ "$(cat third_box.txt)" != "" ]; do  
            folder_paths=($(cat third_box.txt))
            path_to_folder_ends=($(grep -E '' third_box.txt | rev | cut -d'/' -f1 | rev))

            for (( i=0; i <= $(($(grep -c $ third_box.txt)-1)); i++ ))
            do
            mkdir -p $output/${path_to_folder_ends[i]}

            cp -r ${folder_paths[i]}/* $output/${path_to_folder_ends[i]}/
            rm -r ${folder_paths[i]}
            done
            find $output -type d -empty > empty_folders.txt
            while [ "$(cat empty_folders.txt)" != "" ]; do
                find $output -type d -empty -exec rmdir {} +
                find $output -type d -empty > empty_folders.txt
            done
            find $output -maxdepth $(($maximal_depth-1)) -type d -print > box.txt
            find $output -maxdepth $maximal_depth -type d -print > second_box.txt
            sed -i 1d box.txt 
            sed -i 1d second_box.txt

            cat second_box.txt box.txt box.txt | sort | uniq --unique > third_box.txt 

        done
    fi

    
fi


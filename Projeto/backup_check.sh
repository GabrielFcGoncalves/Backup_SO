#!/bin/bash

function check_dir_integ(){
    if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Error: Source directory '$1' is not a valid path."
    exit 1
    fi

    if [ -z "$2" ] || [ ! -d "$2" ]; then
        echo "Error: Destination directory '$2' is not a valid path."
        exit 1
    fi
}


function dir_checker(){

    diretoria_atual="$1"
    path_diretoria_destino="$2"

    original_dir=$(dirname "$starting_dir")
    backup_dir=$(dirname "$path_diretoria_destino")

    for file in "$diretoria_atual"/*; do
        
        relative_path="${file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"

        if [ -f "$file" ]; then

            md5_source=$(md5sum "$file" | awk '{ print $1 }')
            md5_backup=$(md5sum "$path_backup_file" | awk '{ print $1 }')


            if [ "$md5_source" != "$md5_backup" ]; then
                echo "${file#$original_dir/} ${path_backup_file#$backup_dir/} differ."
            fi

        else  
            dir_checker "$file" "$path_diretoria_destino"
        fi
   
    done
}

check_dir_integ $1 $2

starting_dir=$1
if [[ "$starting_dir" != /* ]]; then
    starting_dir=$(realpath "$1")
fi

end_dir=$2
if [[ "$end_dir" != /* ]]; then
    end_dir=$(realpath "$2")
fi

dir_checker $starting_dir $end_dir
#!/bin/bash

function check_dir_integ(){
    if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Error: Source directory '$1' is not a valid path."
    exit 1
    fi

    if [ -z "$2" ]; then
        echo "Error: Destination directory '$2' is not a valid path."
        exit 1
    fi
}

function iterador_diretoria(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        path_original_file="$file"
        relative_path="${path_original_file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"
        
        backup_dir=$(dirname "$path_backup_file")
        mkdir -p "$backup_dir"

        if [ -f "$file" ]; then
            cp -a "$file" "$path_backup_file"
            echo "Copied file: $file to $path_backup_file"
        elif [ -d "$file" ]; then
            echo "Entering directory: $file"
            iterador_diretoria "$file" "$path_diretoria_destino"
        fi
    done
}

function main(){
    
    path_diretoria_destino="$2/$(basename "$starting_dir")_backup"
  
   if [ ! -e "$path_diretoria_destino" ]; then
        echo "$path_diretoria_destino does not exist."
        mkdir -p "$path_diretoria_destino"
        echo "$path_diretoria_destino has been created"
        iterador_diretoria "$starting_dir" "$path_diretoria_destino"
    else
        echo "$path_diretoria_destino already exists."
        ./Iterador_Backup.sh "$starting_dir" "$path_diretoria_destino"
    fi
    

}

check_flag=false

while getopts ":c" opt; do
    case $opt in
        c)
            check_flag=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

check_dir_integ $1 $2

starting_dir=$1
if [[ "$starting_dir" != /* ]]; then
    starting_dir=$(realpath "$1")
fi

main $1 $2

if $check_flag; then
    echo "Using -c param"
fi

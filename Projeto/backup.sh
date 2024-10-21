#!/bin/bash

function check_dir_integ(){
    if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Error: Source directory '$1' is not a valid path."
    exit 1
    fi

    if [ -z "$2" ] || [ ! -d "$1" ]; then
        echo "Error: Destination directory '$2' is not a valid path."
        exit 1
    fi
}

# Function to read exclusion list from a file
function read_exclusion_list() {
    local exclusion_file="$1"
    exclusion_list=()
    while IFS= read -r line; do
        if [[ "$line" != /* ]]; then
            line="$starting_dir/$line"
        fi
        exclusion_list+=("$line")
    done < "$exclusion_file"
}

# Function to check if a file or directory is in the exclusion list
function is_excluded() {
    local path="$1"
    for excluded in "${exclusion_list[@]}"; do
        if [[ "$path" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

function iterador_diretoria(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        relative_path="${file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"
        
        backup_dir=$(dirname "$path_backup_file")

        if is_excluded "$file"; then
            echo "Skipping excluded file or directory: $file"
            continue
        fi

        if [ ! -e "$backup_dir" ]; then
            mkdir -p "$backup_dir"
        fi

        if [ -f "$file" ]; then
            cp -a "$file" "$path_backup_file"
            echo "Copied file: $file to $path_backup_file"
        elif [ -d "$file" ]; then
            echo "Entering directory: $file"
            iterador_diretoria "$file" "$path_diretoria_destino"
        fi
    done
}

function iterador_diretoria_c(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        relative_path="${file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"
        
        backup_dir=$(dirname "$path_backup_file")

        if is_excluded "$file"; then
            echo "Skipping excluded file or directory: $file"
            continue
        fi

        if [ ! -e "$backup_dir" ]; then
            echo "mkdir -p" "$backup_dir"
        fi

        if [ -f "$file" ]; then
            echo "cp -a" "$file" "$path_backup_file"
        elif [ -d "$file" ]; then
            iterador_diretoria_c "$file" "$path_diretoria_destino"
        fi
    done
}

function main(){
    check_dir_integ $1 $2

    starting_dir=$1
    if [[ "$starting_dir" != /* ]]; then
        starting_dir=$(realpath "$1")
    fi

    end_dir=$2
    if [[ "$end_dir" != /* ]]; then
        end_dir=$(realpath "$2")
    fi

    path_diretoria_destino="$end_dir/$(basename "$starting_dir")_backup"
    
    if $check_flag_b; then
        echo "-b enabled with file $file_txt."
        read_exclusion_list "$file_txt"
    fi

    if $check_flag_c; then
        echo "-c enabled."
        iterador_diretoria_c "$starting_dir" "$path_diretoria_destino"
    fi


    if ! $check_flag_c; then
        if [ ! -e "$path_diretoria_destino" ]; then
            echo "$path_diretoria_destino does not exist. Creating it."
            mkdir -p "$path_diretoria_destino"
        fi
        iterador_diretoria "$starting_dir" "$path_diretoria_destino"
    fi
}

check_flag_c=false
check_flag_b=false
file_txt=""

while getopts ":cb:" opt; do
    case $opt in
        c)
            check_flag_c=true
            ;;
        b)
            check_flag_b=true
            file_txt="$OPTARG"
            if [ ! -f "$file_txt" ]; then
                echo "Error: Backup file '$file_txt' not found."
                exit 1
            fi
            if [[ "$file_txt" != /* ]]; then
                file_txt=$(realpath "$file_txt")
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [-c] [-b backup_file] source_path dest_path"
    exit 1
fi

main "$1" "$2"
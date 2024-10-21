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
        relative_path="${file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"
        
        backup_dir=$(dirname "$path_backup_file")

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

     if $check_flag_c; then
        echo "-c enabled."
        iterador_diretoria_c "$starting_dir" "$path_diretoria_destino"
    fi

    if $check_flag_b; then
        echo "-b enabled."
    fi

    if ! $check_flag_c; then
        echo "No flags were provided. Proceeding with normal backup."
        if [ ! -e "$path_diretoria_destino" ]; then
            echo "$path_diretoria_destino does not exist. Creating it."
            mkdir -p "$path_diretoria_destino"
        fi
        iterador_diretoria "$starting_dir" "$path_diretoria_destino"
    fi

}

ccheck_flag_c=false
file_txt=""

while getopts ":cb" opt; do
    case $opt in
        c)
            check_flag_c=true
            ;;
        b)
            file_txt="$OPTARG"
            if [ ! -f "$file_txt" ]; then
                echo "Error: Backup file '$file_txt' not found."
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

main $1 $2

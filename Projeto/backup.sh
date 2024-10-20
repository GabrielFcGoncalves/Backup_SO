#!/bin/bash

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
    backup="${path_diretoria_destino}_backup"
  
   if [ ! -e "$path_diretoria_destino" ]; then
        echo "$backup does not exist."
        mkdir -p "$path_diretoria_destino"
        echo "$backup has been created"
        iterador_diretoria "$starting_dir" "$path_diretoria_destino"
    else
        echo "$backup already exists."
        ./Iterador_Backup.sh "$starting_dir" "$path_diretoria_destino"
    fi
    

}


starting_dir=$1

# Check if the input path is absolute or relative
if [[ "$starting_dir" = /* ]]; then
  echo "Absolute path provided."
else
  echo "Relative path provided."
  starting_dir=$(realpath "$1")
    echo $starting_dir "REAL PATH"
fi

main $1 $2

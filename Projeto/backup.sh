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
    
    diretoria_a_copiar="$1"
    backup="${diretoria_a_copiar}_backup"
    path_diretoria_destino="$2/$(basename "$1")_backup"
  
   if [ ! -e "$path_diretoria_destino" ]; then
        echo "$backup does not exist."
        mkdir "$path_diretoria_destino"
        echo "$backup has been created"
        iterador_diretoria "$diretoria_a_copiar" "$path_diretoria_destino"
    else
        echo "$backup already exists."
        ./Iterador_Backup.sh "$diretoria_a_copiar" "$path_diretoria_destino"
    fi
    

}


starting_dir=$1
main $1 $2

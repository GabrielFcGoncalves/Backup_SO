#!/bin/bash

function iterador_diretoria(){

    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        
        path_original_file="$file"
        relative_path="${path_original_file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path"

        if [ -f "$path_original_file" ]; then

            md5_source=$(md5sum "$path_original_file" | awk '{ print $1 }')
            md5_backup=$(md5sum "$path_backup_file" | awk '{ print $1 }')

            if [ "$md5_source" != "$md5_backup" ]; then
                echo "$path_original_file $path_backup_file differ."
            fi
            else  iterador_diretoria "$file" "$path_diretoria_destino"
        fi
   
    done
}

path_diretoria_destino="$2/$(basename "$1")_backup"
starting_dir=$1
iterador_diretoria $starting_dir $path_diretoria_destino
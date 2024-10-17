#!/bin/bash

function iterador_diretoria(){

    diretoria_inicial=$(echo "$1" | cut -d'/' -f1)
    diretoria_atual="$1"
    backup="${diretoria_atual}_backup"
    path_diretoria_destino="$2/${backup}"

    for file in "$diretoria_atual"/*; do
        
        original_file="$file"
        backup_file="${path_diretoria_destino}${file#"$diretoria_inicial"}"

        if [ -f "$file" ]; then

            md5_source=$(md5sum "$file" | awk '{ print $1 }')
            md5_backup=$(md5sum "$backup_file" | awk '{ print $1 }')

            if [ "$md5_source" != "$md5_backup" ]; then
                echo "$original_file $backup_file differ."
            fi
        fi

    done
}

iterador_diretoria "$1" "$2"
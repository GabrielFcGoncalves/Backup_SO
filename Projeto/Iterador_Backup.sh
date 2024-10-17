#!/bin/bash

function iterador_diretoria(){

    diretoria_inicial=$(echo "$1" | cut -d'/' -f1)
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        
        original_file="$file"
        backup_file="${path_diretoria_destino}${file#"$diretoria_inicial"}"

        if [ -f "$file" ]; then

            if [ ! -e "$backup_file" ]; then
                echo "File $file is new. Backing up."
                mkdir -p "$(dirname "$backup_file")"  
                cp -a "$file" "$backup_file"

            else

                md5_source=$(md5sum "$file" | awk '{ print $1 }')
                md5_backup=$(md5sum "$backup_file" | awk '{ print $1 }')

                if [ "$md5_source" != "$md5_backup" ]; then
                    echo "File $file has been updated. Backing up now."
                    cp -a "$file" "$backup_file"
                fi
            fi
        fi

        if [ -d "$file" ]; then
            if [ ! -e "$backup_file" ]; then
                echo "Directory $file is new. Creating and backing up."
                mkdir -p "$backup_file"
            fi
            
            iterador_diretoria "$file" "$path_diretoria_destino"
        fi

    done
}

iterador_diretoria "$1" "$2"
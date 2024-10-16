#!/bin/bash

function iterador_diretoria(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"
    prefixo="$3"

    for file in "$diretoria_atual"/*; do
        
        path_original_file="${file}"

        aux=${file#"$prefixo"}

        path_backup_file="${path_diretoria_destino}${aux}"
        echo "Ficheiro --------------__> $file"

        # if [ -e "$path_original_file" ]; then
        #         echo "Tudo ok"
        #     else
        #         echo "------------------------------------File '$ficheiro_backup' does not exist in '$path_original_file'."
        # fi

        
        if [ -f "$file" ]; then
            cp -a "$file" "$path_backup_file"
        fi

        if [ -d "$file" ]; then

            # for ficheiro_backup in "$path_backup_file"/*; do
              
            #     if [ -e "$path_original_file/$(basename "$ficheiro_backup")" ]; then
            #         echo "Tudo ok"
            #     else
            #         echo "------------------------------------File '$ficheiro_backup' does not exist in '$path_original_file'."
            #     fi

            # done
            mkdir "$path_backup_file"
            ./Iterador_diretoria.sh $file $path_diretoria_destino $prefixo
        fi
        

    done

}

iterador_diretoria $1 $2 $3
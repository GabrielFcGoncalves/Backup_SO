#!/bin/bash

function iterador_diretoria(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"
    prefixo="$3"

  
    for file in "$diretoria_atual"/*; do
        
        
            path_original_file="${file}"

            path_backup_file="${path_diretoria_destino}${file#"$prefixo"}"


            
            if [ -f "$file" ]; then
                cp -a "$file" "$path_backup_file"
            fi

            if [ -d "$file" ]; then

                if [ ! -d "$path_backup_file" ]; then
                    mkdir "$path_backup_file"
            
                fi
                
                ./Iterador_diretoria.sh $file $path_diretoria_destino $prefixo   
                
                
            fi
            

    done

}

iterador_diretoria $1 $2 $3
#!/bin/bash

function iterador_diretoria(){
    diretoria_incial=$(echo $1 | cut -d'/' -f1)
    diretoria_atual="$1"
    path_diretoria_destino="$2"
  
    for file in "$diretoria_atual"/*; do
        
        
            path_original_file="${file}"

            path_backup_file="${path_diretoria_destino}${file#"$diretoria_incial"}"


            
            if [ -f "$file" ]; then
                cp -a "$file" "$path_backup_file"
            fi

            if [ -d "$file" ]; then

                if [ ! -d "$path_backup_file" ]; then
                    mkdir "$path_backup_file"
            
                fi
                
                ./Iterador_diretoria.sh $file $path_diretoria_destino $diretoria_incial   
                
                
            fi
            

    done

}

iterador_diretoria $1 $2 $3
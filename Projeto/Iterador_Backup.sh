#!/bin/bash

function iterador_diretoria(){
    diretoria_incial=$(echo $1 | cut -d'/' -f1)
    diretoria_atual="$1"
    path_diretoria_destino="$2"
  
    for file in "$diretoria_atual"/*; do
        
        
            path_original_file="${file}"

            backup_file="${path_diretoria_destino}${file#"$diretoria_incial"}"


            if [ -f "$file" ]; then
                if [ ! -e "$file" ]; then
                    echo "File $file is new. Backing up."
                    cp -a "$file" "$backup_file"
                elif [ "$file" -nt "$backup_file" ]; then
                    echo "Source file $file has been updated. Backing up now."
                    cp -a "$file" "$backup_file"
                fi
            fi

            if [ -d "$file" ]; then
                if [ ! -e "$backup_file" ];  then
                    echo "Dir $file is new. Backing up."
                    mkdir "$backup_file"
                elif [ "$file" -nt "$backup_file" ]; then
                    echo "Dir $file has been updated. Backing up now."
                    mkdir "$backup_file"
                fi
                
                ./Iterador_diretoria.sh $file $path_diretoria_destino 
    
            fi
            

    done

}

iterador_diretoria $1 $2 
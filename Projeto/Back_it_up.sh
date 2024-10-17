#!/bin/bash

function main(){
    
    diretoria_a_copiar="$1"
    backup="${diretoria_a_copiar}_backup"
    path_diretoria_destino="$2/${backup}"
  

   if [ ! -e "$path_diretoria_destino" ]; then
        echo "$backup does not exist."
        mkdir "$path_diretoria_destino"
        ./Iterador_diretoria.sh "$diretoria_a_copiar" "$path_diretoria_destino"
        echo "$backup has been created"
    else
        echo "$backup already exists."
        ./Iterador_Backup.sh "$diretoria_a_copiar" "$path_diretoria_destino"
    fi
    

}


main $1 $2

#!/bin/bash

function main(){
    
    diretoria_a_copiar="$1"
    backup="${diretoria_a_copiar}_backup"
    path_diretoria_destino="$2/${backup}"
  

    if [ ! -d "$backup" ]; then
        echo "$backup does not exist."
        mkdir $path_diretoria_destino
        echo "$backup has been created"
    fi

    ./Iterador_diretoria.sh $diretoria_a_copiar $path_diretoria_destino $diretoria_a_copiar

    

}


main $1 $2 $3

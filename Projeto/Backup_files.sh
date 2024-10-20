        
function Backup_files(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do

        
        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
                echo "File $file is new. Backing up." 
                cp -a "$file" "$path_diretoria_destino"

            else

                md5_source=$(md5sum "$file" | awk '{ print $1 }')
                md5_backup=$(md5sum "$path_diretoria_destino/$(basename $file)" | awk '{ print $1 }')

                if [ "$md5_source" != "$md5_backup" ]; then
                        echo "File $(basename $file) has been updated. Backing up now."
                        cp -a "$file" "$path_diretoria_destino"
                fi
            fi
        fi


    done
}


function main(){
    
    diretoria_a_copiar="$1"
    path_diretoria_destino="$2/$(basename "$1")_backup"
  
   if [ ! -e "$path_diretoria_destino" ]; then
        echo "$backup does not exist."
        mkdir "$path_diretoria_destino"
        Backup_files "$diretoria_a_copiar" "$path_diretoria_destino"
        echo "$backup has been created"
    else
        echo "$backup already exists."
        Backup_files "$diretoria_a_copiar" "$path_diretoria_destino"
    fi
    

}


main $1 $2
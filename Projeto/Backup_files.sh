
function Backup_files(){
    diretoria_incial=$(echo $1 | cut -d'/' -f1)
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
        
            path_original_file="${file}"

            path_backup_file="${path_diretoria_destino}/$(basename "$file")"

            echo $file
            
            if [ -f "$file" ]; then
                cp -a "$file" "$path_backup_file"
            fi
    done
}

Backup_files $1 $2
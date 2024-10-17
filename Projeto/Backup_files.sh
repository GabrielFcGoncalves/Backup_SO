
function Backup_files(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do

        path_original_file="$file"
    
        relative_path="${path_original_file#$starting_dir/}"  
        backup_file="$path_diretoria_destino/$relative_path" 

        
        if [ -f "$file" ]; then

            if [ ! -e "$backup_file" ]; then
                echo "File $file is new. Backing up." 
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
    done
}


starting_dir="$1"
Backup_files $1 $2
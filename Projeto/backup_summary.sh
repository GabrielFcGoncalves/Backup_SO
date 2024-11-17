#!/bin/bash
#antigo belito
function check_dir_integ(){
    if  ! $flag_c ;then
        if [ -z "$1" ] || [ ! -d "$1" ]; then
            echo "Error: Source directory '$1' is not a valid path."
            exit 1
        fi

        if [ ! -e "$2" ] && [ -d "$(dirname "$2")" ]; then
            execute mkdir -p "$2"
        fi
        

        if [ -z "$2" ] || [ ! -d "$2" ]; then
            echo "Error: Destination directory '$2' is not a valid path."
            exit 1
        fi
        

        if [ "$1" == "$2" ]; then
            echo "Erro: O diretório de origem e destino não podem ser os mesmos."
            exit 1
        fi

        if [[ ! -r "$1" ]]; then
            echo "Erro: Sem permissão de leitura no diretório '$1'."
            exit 1
        fi

        if [[ ! -w "$2" ]] || [[ ! -r "$2" ]]; then
            echo "Erro: Sem permissão de escrita ou de leitura no diretório '$2'."
            exit 1
        fi
    fi
}


execute() {
    
    if [ "$flag_c" = "false" ]; then
        "$@" || { ((errors++)); return 1; }
    fi

    return 0

}

function read_exclusion_list() {
    local exclusion_file="$1"
    exclusion_list=()
    while IFS= read -r line; do 
        exclusion_list+=("$line")
    done < "$exclusion_file"
}

function is_excluded() {
    local path="$1"
    for excluded in "${exclusion_list[@]}"; do
        excluded="$2/$(basename "$excluded")" && [[ "$excluded" != /* ]] 
        [[ "$path" == "$excluded" || "$path" == "$excluded/"* ]] && return 0
    done
    return 1
}

function backup_gen(){

    local diretoria_atual="$1"
    local path_diretoria_destino="$2"

    local copied=0
    local updated=0
    local errors=0
    local warnings=0
    local deleted=0
    local size_deleted=0
    local size_copied=0

    dir_backup="$path_diretoria_destino/${diretoria_atual#$starting_dir/}"

    [ "$diretoria_atual" == "$starting_dir" ] && dir_backup="$path_diretoria_destino"

    

    if [[ ! -d "$dir_backup" ]] ;then
        execute mkdir -p "$dir_backup"
        [ $dir_backup != $end_dir ] && echo "mkdir $(basename "$end_dir")${dir_backup#$end_dir}"
    fi

    for file in "$diretoria_atual"/*; do

        path_backup_file="$path_diretoria_destino/${file#$starting_dir/}"
      
        path_original_dir="$starting_dir/${diretoria_atual#$starting_dir/}"
        relative_backup_file="$(basename "$end_dir")/${path_backup_file#$end_dir/}"
        relative_path="$(basename "$starting_dir")/${file#$starting_dir/}"

        if is_excluded "$file" "$diretoria_atual"; then
            echo "Skipping excluded file or directory: $relative_path"
            ((warnings++))
            continue
        fi

      

        

        backup_dir=$(dirname "$path_backup_file")
        
        if [ ! -e $path_backup_file ]; then

           
            
            
            if [ -f "$file" ]; then
                if [[ ! "$file" =~ $expression ]] && [[ $flag_r ]] ; then
                    echo "Skipping $relative_path: doesnt match the provided expression. "
                    ((warnings++))
                    continue
                elif [ ! -e "$path_backup_file" ]; then 
                    execute cp -a "$file" "$path_backup_file"
                    echo "cp -a $relative_path $relative_backup_file"
                    if [ $? -eq 0 ];then
                        ((copied++)) 
                        size_copied=$((size_copied + $(stat --format="%s" "$file")))
                    fi 
                fi    

            elif [ -d "$file" ]; then
                backup_gen "$file" "$path_diretoria_destino" 
            fi
            
        
        else

            if [ -f "$path_backup_file" ]; then
            
                if [ "$file" -nt "$path_backup_file" ];then                    
                        execute cp -a "$file" "$path_backup_file"
                        echo "cp -a $relative_path $relative_backup_file"
                        [ $? -eq 0 ] && ((updated++)) #&& ((warnings++))
                fi

            elif [ -d "$file" ]; then
                backup_gen "$file" "$path_diretoria_destino" 
            fi
        fi


        

    done

    path_backup_dir="$path_diretoria_destino/${diretoria_atual#$starting_dir/}"

    [ "$diretoria_atual" == "$starting_dir" ] && path_backup_dir="$path_diretoria_destino"
    
    if [ -d  "$path_backup_dir" ];then
        count_backup=$(ls -1 "$path_backup_dir" | wc -l)
        count_original=$(ls -1 "$diretoria_atual" | wc -l)

        if [ "$count_backup" -gt "$count_original" ]; then

            for backupfile in "$path_backup_dir"/*; do
                filename=$(basename "$backupfile")
                
                if [ ! -e "$diretoria_atual/$filename" ]; then

                    if [ -f "$backupfile" ]; then
                        aux_cum=$(stat --format=%s "$backupfile")
                        aux_count=1
                        execute rm "$backupfile"
                        echo "rm $(basename "$end_dir")${backupfile#$end_dir}"
                    elif [ -d "$backupfile" ]; then
                        aux_cum=$(du -sb "$backupfile" | cut -f1)
                        aux_count=$(find "$backupfile" -type f | wc -l)
                        execute rm -r "$backupfile"
                        echo "rm -r $(basename "$end_dir")${backupfile#$end_dir}"
                    fi

                    if [ $? -eq 0 ]; then
                        size_deleted=$((size_deleted + aux_cum))
                        deleted=$((deleted + aux_count))
                    fi
                fi

            done

        fi
    fi


    echo "While backuping ${diretoria_atual#$dir/}: $errors Errors; $warnings Warnings; $updated Updated; $copied Copied (${size_copied}B); $deleted Deleted (${size_deleted}B)"
}

function main(){
    check_dir_integ $1 $2

    starting_dir=$(readlink -f "$1")
    end_dir=$(realpath "$2") 

    if $flag_b; then
        read_exclusion_list "$file_txt"
    fi
        
    backup_gen "$starting_dir" "$end_dir" 
}

dir=$(pwd)
flag_c=false
flag_b=false
flag_r=false
file_txt=""
expression=""

while getopts ":cb:r:" opt; do
    case $opt in
        c)
            flag_c=true
            ;;
        b)
            flag_b=true
            file_txt="$OPTARG"
            if [ ! -f "$file_txt" ]; then
                echo "Error: Backup file '$file_txt' not found."
                exit 1
            fi
            [[ "$file_txt" != /* ]] && file_txt=$(realpath "$file_txt")
            ;;
        r)
            flag_r=true
            expression="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [-c] [-b backup_file] source_path dest_path"
    exit 1
fi

main "$1" "$2"
#!/bin/bash
#antigo belito
function check_dir_integ(){
    if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Error: Source directory '$1' is not a valid path."
    exit 1
    fi

    if [ -z "$2" ] || [ ! -d "$1" ]; then
        echo "Error: Destination directory '$2' is not a valid path."
        exit 1
    fi
}

execute() {
   
    if [ "$flag_c" = "false" ];then
        eval "${@}"
        status="$?"
        if [ $status != '0' ];then
            ((errors = errors + 1))
            ((copied = copied -1))
            return
        fi

        echo "${@}"
    else
        echo "${@}"
    fi

}

function read_exclusion_list() {
    local exclusion_file="$1"
    exclusion_list=()
    while IFS= read -r line; do
        if [[ "$line" != /* ]]; then
            line="$starting_dir/$line"
        fi
        exclusion_list+=("$line")
    done < "$exclusion_file"
}

function is_excluded() {
    local path="$1"
    for excluded in "${exclusion_list[@]}"; do
        if [[ "$path" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

function backup_gen(){

    local diretoria_atual="$1"
    local path_diretoria_destino="$2"

    local copied=0
    local updated=0
    local errors=0

    for file in "$diretoria_atual"/*; do

        relative_path_start="${file#$starting_dir/}"
        path_backup_file="$path_diretoria_destino/$relative_path_start"

        relative_path_end="${file#$end_dir/$dir_backup}"
        path_original_path="$diretoria_atual$relative_path_end"
        
        backup_dir=$(dirname "$path_backup_file")

        if [ ! -e $path_backup_file ]; then

            if is_excluded "$file"; then
                echo "Skipping excluded file or directory: $file"
                continue
            fi

            if [ ! -e "$backup_dir" ]; then
                execute mkdir -p "$backup_dir"
            fi

            if [ -f "$file" ]; then
                if $flag_r; then
                    if [[ ! "$file" =~ $expression ]]; then
                        echo "Skipping $file: doesnt match the provided expression. "
                        continue
                    fi
                fi
                if [ ! -e "$path_backup_file" ]; then 
                    execute cp -a "$file" "$path_backup_file"
                    ((copied = copied+1)) 
                fi    

            elif [ -d "$file" ]; then
                backup_gen "$file" "$path_diretoria_destino" 
            fi           
            
        
        else

            if is_excluded "$file"; then
                echo "Removing $path_backup_file from the backup as it is in the provided exclusion path_backup_file."
                if [ -f $path_backup_file ]; then
                    execute rm $path_backup_file
                else 
                    execute rm -r $path_backup_file
                fi
                continue
            fi

            if [ -f "$path_backup_file" ]; then

                if $flag_r; then
                    if [[ ! "$path_backup_file" =~ $expression ]]; then
                        echo "Deleting $path_backup_file: doesnt match the provided expression. "
                        execute rm $path_backup_file
                        continue
                    fi
                fi

                if [ ! -e $file ]; then
                    (( errors = errors + 1 ))
                    execute rm $path_backup_file;
                else
                    md5_source=$(md5sum "$path_backup_file" | awk '{ print $1 }')
                    md5_backup=$(md5sum "$file" | awk '{ print $1 }')

                    if [ "$md5_source" != "$md5_backup" ]; then
                        echo "File $(basename $path_backup_file) has been updated."                        
                        execute "cp -a" "$file" "$path_backup_file"
                        ((updated = updated+1)) 
                    fi
                fi

            elif [ -d "$file" ]; then
                if [ ! -e "$file" ]; then
                    echo "Dir $file has been deleted. Skipping."
                    execute rm -r $path_backup_file
                    continue
                else
                    backup_gen "$file" "$path_diretoria_destino" 
                fi
            fi
        fi
    done

    echo "While backing $diretoria_atual: $errors warnings, $copied copied, $updated updated."
}

function main(){
    check_dir_integ $1 $2

    starting_dir=$1
    if [[ "$starting_dir" != /* ]]; then
        starting_dir=$(readlink -f "$1")
    fi

    end_dir=$2
    if [[ "$end_dir" != /* ]]; then
        end_dir=$(realpath "$2")
    fi

    dir_backup="$(basename "$starting_dir")_backup"

    path_diretoria_destino="$end_dir/${dir_backup}"    

    if $flag_b; then
        echo "-b enabled with file $file_txt."
        read_exclusion_list "$file_txt"
    fi

    if [ ! -e "$path_diretoria_destino" ]; then
        echo "$path_diretoria_destino does not exist. Creating it."
        execute mkdir -p "$path_diretoria_destino"
    fi
    backup_gen "$starting_dir" "$path_diretoria_destino" 
}

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
            if [[ "$file_txt" != /* ]]; then
                file_txt=$(realpath "$file_txt")
            fi
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
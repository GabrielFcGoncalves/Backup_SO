#!/bin/bash
#antigo belito
function check_dir_integ(){
    if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Error: Source directory '$1' is not a valid path."
    exit 1
    fi

    if [ -z "$2" ] || [ ! -d "$2" ]; then
        echo "Error: Destination directory '$2' is not a valid path."
        exit 1
    fi
}

execute() {

    if [ "$flag_c" = "false" ];then
        eval "${@}" || {((errors++)); ((copied--));return;}
    fi
    echo "${@}"
}

function read_exclusion_list() {
    local exclusion_file="$1"
    exclusion_list=()
    while IFS= read -r line; do
        [[ "$line" != /* ]] && line="$starting_dir/$line"
        exclusion_list+=("$line")
    done < "$exclusion_file"
}

function is_excluded() {
    local path="$1"
    for excluded in "${exclusion_list[@]}"; do
        [[ "$path" == "$excluded" ]] && return 0
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


        backup_dir=$(dirname "$path_backup_file")
        
        if [ ! -e $path_backup_file ]; then

            if is_excluded "$file"; then
                echo "Skipping excluded file or directory: $file"
                continue
            fi

            [ ! -e "$backup_dir" ] && execute mkdir -p "$backup_dir"
            
            if [ -f "$file" ]; then
                if [[ ! "$file" =~ $expression ]] && [[ $flag_r ]] ; then
                    echo "Skipping $file: doesnt match the provided expression. "
                    continue
                elif [ ! -e "$path_backup_file" ]; then 
                    execute cp -a "$file" "$path_backup_file"
                    ((copied++)) 
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

                if [[ ! "$path_backup_file" =~ $expression ]] && [[ $flag_r ]]; then
                    echo "Deleting $path_backup_file: doesnt match the provided expression. "
                    execute rm $path_backup_file
                    continue
                fi
            
                if [ ! -e $file ]; then
                    (( errors++))
                    execute rm $path_backup_file;
                elif [ $path_backup_file -ot $file ];then                    
                        execute "cp -a" "$file" "$path_backup_file"
                        ((updated++)) 
                fi

            elif [ -d "$file" ]; then
                if [ ! -e "$file" ]; then
                    echo "Dir $file has been deleted. Skipping."
                    execute rm -r $path_backup_file
                    continue
                fi
                backup_gen "$file" "$path_diretoria_destino" 
            fi
        fi
    done

    echo "While backing $diretoria_atual: $errors warnings, $copied copied, $updated updated."
    echo -e "\n"
}

function main(){
    check_dir_integ $1 $2

    starting_dir=$1
    [[ "$starting_dir" != /* ]] && starting_dir=$(readlink -f "$1")


    end_dir=$2
    [[ "$end_dir" != /* ]] && end_dir=$(realpath "$2")

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
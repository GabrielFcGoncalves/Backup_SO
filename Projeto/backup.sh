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
            ((error_count = error_count + 1))
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
    diretoria_atual="$1"
    path_diretoria_destino="$2"
    mode="$3"

    for file in "$diretoria_atual"/*; do
        
        case $mode in 
            0)
                relative_path="${file#$starting_dir/}"
                path_backup_file="$path_diretoria_destino/$relative_path"
                
                backup_dir=$(dirname "$path_backup_file")

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
                    fi    

                elif [ -d "$file" ]; then
                    echo "Entering directory: $file"
                    backup_gen "$file" "$path_diretoria_destino" "$mode"
                fi
                ;;
            
            1)
                relative_path="${file#$end_dir/$dir_backup}"
                path_original_path="$path_diretoria_destino$relative_path"

                if is_excluded "$path_original_path"; then
                    echo "Removing $file from the backup as it is in the provided exclusion file."
                    if [ -f $file ]; then
                        execute rm $file
                    else 
                        execute rm -r $file
                    fi
                    continue
                fi

                if [ -f "$file" ]; then

                    if $flag_r; then
                        if [[ ! "$file" =~ $expression ]]; then
                            echo "Deleting $file: doesnt match the provided expression. "
                            execute rm $file
                            continue
                        fi
                    fi

                    if [ ! -e $path_original_path ]; then
                        (( error_count = error_count + 1 ))
                        execute rm $file;
                    else
                        md5_source=$(md5sum "$file" | awk '{ print $1 }')
                        md5_backup=$(md5sum "$path_original_path" | awk '{ print $1 }')

                        if [ "$md5_source" != "$md5_backup" ]; then
                            echo "File $(basename $file) has been updated."                        
                            execute "cp -a" "$path_original_path" "$file"
                        fi
                    fi

                elif [ -d "$file" ]; then
                    if [ ! -e "$path_original_path" ]; then
                        echo "Dir $path_original_path has been deleted. Skipping."
                        execute rm -r $file
                        continue
                    else
                        #echo "Entering directory: $file"
                        echo "While backing $diretoria_atual $error_count warnings were detected"
                        error_count=0;
                        backup_gen "$file" "$path_diretoria_destino" "$mode"
                    fi
                fi

                ;;
                

        esac
    done
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
    backup_gen "$starting_dir" "$path_diretoria_destino" "0"
    backup_gen  "$path_diretoria_destino" "$starting_dir" "1"
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
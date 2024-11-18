        
function check_dir_integ(){
    if ! $check_flag ;then  

        if [ ! -e "$2" ]; then
            mkdir -p "$2"
        fi

        if [ ! -d "$1" ]; then
        echo "Error: Source directory '$1' is not a valid path."
        exit 1
        fi

        if [ ! -d "$2" ]; then
            echo "Error: Destination directory '$2' is not a valid path."
            exit 1
        fi

    fi
}

function Backup_files(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
    path_backup_file="$path_diretoria_destino/${file#$starting_dir/}"
    relative_backup_file="$(basename "$end_dir")/${path_backup_file#$end_dir/}"

        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
               echo "cp -a" "${file#$dir/}" "$relative_backup_file"
                cp -a "$file" "$path_diretoria_destino"

            elif [ "$path_diretoria_destino" -ot "$file" ]; then
                echo "${file#$dir/}" has been updated.
                echo "cp -a" "${file#$dir/}" "$relative_backup_file"
                cp -a "$file" "$path_diretoria_destino"  
            fi
        fi


    done
}

function Backup_files_c(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do
    path_backup_file="$path_diretoria_destino/${file#$starting_dir/}"
    relative_backup_file="$(basename "$end_dir")/${path_backup_file#$end_dir/}"

        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
               echo "cp -a" "${file#$dir/}" "$relative_backup_file"

            elif [ "$path_diretoria_destino" -ot "$file" ]; then
                echo "cp -a" "${file#$dir/}" "$relative_backup_file" 
            fi
        fi


    done
}


function main(){


    check_dir_integ $1 $2

    starting_dir=$1
    [[ "$starting_dir" != /* ]] && starting_dir=$(realpath "$1")
    
    end_dir=$2
    [[ "$end_dir" != /* ]] && end_dir=$(realpath "$2")

    path_diretoria_destino="$end_dir"

    if $check_flag; then
        Backup_files_c "$starting_dir" "$path_diretoria_destino"
    
    else
        Backup_files "$starting_dir" "$path_diretoria_destino"

    fi

}

check_flag=false
dir=$(pwd)

while getopts ":c" opt; do
    case $opt in
        c)
            check_flag=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
    
main $1 $2  
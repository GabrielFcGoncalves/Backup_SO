        
function check_dir_integ(){
    if ! $check_flag ;then  

        if [ ! -e "$2" ]; then
            mkdir -p "$2"
        fi

        if [ -z "$1" ] || [ ! -d "$1" ]; then
        echo "Error: Source directory '$1' is not a valid path."
        exit 1
        fi

        if [ -z "$2" ] || [ ! -d "$2" ]; then
            echo "Error: Destination directory '$2' is not a valid path."
            exit 1
        fi

    fi
}

function Backup_files(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do

        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
               echo "cp -a" "${file#$starting_dir/}" "$(basename "$path_diretoria_destino")"
                cp -a "$file" "$path_diretoria_destino"

            elif [ "$path_diretoria_destino" -ot "$file" ]; then
                echo "cp -a" "${file#$starting_dir/}" "$(basename "$path_diretoria_destino")"
                cp -a "$file" "$path_diretoria_destino"  
            fi
        fi


    done
}

function Backup_files_c(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do

        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
                echo "cp -a" "${file#$starting_dir/}" "$(basename "$path_diretoria_destino")"

           elif [ $file -nt $path_diretoria_destino ];then   
                echo "cp -a" "${file#$starting_dir/}" "$(basename "$path_diretoria_destino")"
                
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

        [ ! -e "$path_diretoria_destino" ] && Backup_files_c "$starting_dir" "$path_diretoria_destino"
    
    else
        Backup_files "$starting_dir" "$path_diretoria_destino"

    fi

}

check_flag=false

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
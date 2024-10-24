        
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

function Backup_files(){
    diretoria_atual="$1"
    path_diretoria_destino="$2"

    for file in "$diretoria_atual"/*; do

        
        if [ -f "$file" ]; then
            if [ ! -e "$path_diretoria_destino/$(basename $file)" ]; then
                echo "cp -a" "$file" "$path_diretoria_destino"
                cp -a "$file" "$path_diretoria_destino"

            else

                md5_source=$(md5sum "$file" | awk '{ print $1 }')
                md5_backup=$(md5sum "$path_diretoria_destino/$(basename $file)" | awk '{ print $1 }')

                if [ "$md5_source" != "$md5_backup" ]; then
                        echo "File $(basename $file) has been updated. Backing up now."
                        echo "cp -a" "$file" "$path_diretoria_destino"
                        cp -a "$file" "$path_diretoria_destino"
                fi
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
                echo "cp -a" "$file" "$path_diretoria_destino"

            else

                md5_source=$(md5sum "$file" | awk '{ print $1 }')
                md5_backup=$(md5sum "$path_diretoria_destino/$(basename $file)" | awk '{ print $1 }')

                if [ "$md5_source" != "$md5_backup" ]; then
                        echo "File $(basename $file) has been updated."                        
                        echo "cp -a" "$file" "$path_diretoria_destino"
                fi
            fi
        fi


    done
}


function main(){


    check_dir_integ $1 $2

    starting_dir=$1
    if [[ "$starting_dir" != /* ]]; then
        starting_dir=$(realpath "$1")
    fi
    end_dir=$2
    if [[ "$end_dir" != /* ]]; then
        end_dir=$(realpath "$2")
    fi

    path_diretoria_destino="$end_dir/$(basename "$starting_dir")_backup"

    if $check_flag; then
        if [ ! -e "$path_diretoria_destino" ]; then
            echo "mkdir" "$path_diretoria_destino"
            Backup_files_c "$starting_dir" "$path_diretoria_destino"
        else Backup_files_c "$starting_dir" "$path_diretoria_destino"
        fi     

    else
        if [ ! -e "$path_diretoria_destino" ]; then
            echo "$path_diretoria_destino does not exist."
            mkdir "$path_diretoria_destino"
            Backup_files "$starting_dir" "$path_diretoria_destino"
            echo "$path_diretoria_destino has been created"
        else
            echo "$path_diretoria_destino already exists."
            Backup_files "$starting_dir" "$path_diretoria_destino"
        fi
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
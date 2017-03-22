
mcdir(){
    if [ ! -d "$1" ]; then
        mkdir "$1";
    fi;

    cd "$1";
}
export -f mcdir

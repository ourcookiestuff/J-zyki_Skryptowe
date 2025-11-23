#!/usr/bin/env bash
#Jakub Dziurka

set -e

# flagi opcji
LONG="replace-with-hardlinks help max-depth: hash-algo:"
SHORT=""

# wartości domyśle
MAX_DEPTH=10
HASH_ALGO="md5sum"
REPLACE_WITH_HARDLINKS=0
DIR=""

AAA=0
BBB=0
CCC=0

declare -a FILE_LIST
declare -a SIZE_LIST
declare -a FILE_HASH
declare -a ALREADY_LINKED

# Help
printHelp() {
    cat <<EOF
Uzycie: $0 [OPCJE] DIR
Opcje:
  --replace-with-hardlinks: Zastepuje duplikaty hardlinkami
  --max-depth=N: maksymalna glebokosc przeszukiwania
  --hash-algo=ALGO: algorytm haszujacy
  --help  
EOF
}

# sprawdzenie hasza
checkHashAlgo() {
    if ! command -v "$HASH_ALGO" >/dev/null 2>&1; then
        echo "$HASH_ALGO not supported"
        exit 1
    fi
}

# zbieranie plików
collectFiles() {
    tempFILE=$(mktemp ./tmpXXXXXXXXX)

    find "$DIR" -maxdepth $MAX_DEPTH -type f -print0 | while IFS= read -r -d '' file ; do
        size=$(stat -c '%s' "$file")
        printf "%s\t%s\n" "$size" "$file"
    done > "$tempFILE"

    sort -n "$tempFILE" -o "$tempFILE"

}

# grupowanie po rozmiarze
groupBySize() {
    idx=0
    while IFS=$'\t' read -r size path; do
        FILE_LIST[idx]="$path"
        SIZE_LIST[idx]="$size"
        (( AAA += 1 ))
        (( idx += 1 ))
        
    done < "$tempFILE"

    rm -f $tempFILE

	for ((i=0; i<idx; i++)); do
        FILE_HASH[i]=$(computeHash "${FILE_LIST[i]}")
        ALREADY_LINKED[i]=0
    done
}

# obliczanie hasha
computeHash() {
    local file="$1"
    "$HASH_ALGO" "$file" | awk '{print $1}'
}

# funckja przetwarzająca duplikaty
processDuplicates() {
    local n=${#FILE_LIST[@]}
    local start=0
    while ((start < n)); do
        local size=${SIZE_LIST[start]}
        local end=$start
        while (( end+1 < n && SIZE_LIST[end+1] == size )); do
            (( end += 1 ))
        done

        # jeśli więcej niż 1 plik o tym rozmiarze
        if (( end > start )); then
            compareFiles "$start" "$end"
        fi
        start=$((end+1))
    done
}

compareFiles() {
    local s=$1
    local e=$2
    for ((i=s; i<=e; i++)); do
        [[ ${ALREADY_LINKED[i]} -eq 1 ]] && continue
        for ((j=i+1; j<=e; j++)); do
            [[ ${ALREADY_LINKED[j]} -eq 1 ]] && continue
            if [[ ${FILE_HASH[i]} == ${FILE_HASH[j]} ]]; then
                if cmp -s "${FILE_LIST[i]}" "${FILE_LIST[j]}"; then
					(( BBB += 1 ))
					ALREADY_LINKED[j]=1
					if ((REPLACE_WITH_HARDLINKS)); then
						ln -f "${FILE_LIST[i]}" "${FILE_LIST[j]}"
						(( CCC += 1 ))
					fi
				fi
            fi
        done
    done
}

# raport
printReport() {
    echo "Liczba przetworzonych plikow: $AAA"
    echo "Liczba znalezionych duplikatow: $BBB"
    echo "Liczba zastapionych duplikatow: $CCC"
}


# -------------------MAIN-------------------
PARSED=$(getopt --options="$SHORT" --longoptions="$LONG" --name "$0" -- "$@") || exit 2
eval set -- "$PARSED"

while true; do
    case "$1" in
        --help)
            printHelp
            exit 0
            ;;
        --max-depth)
            MAX_DEPTH=$2
            shift 2
            ;;
        --hash-algo)
            HASH_ALGO=$2
            shift 2
            ;;
        --replace-with-hardlinks)
            REPLACE_WITH_HARDLINKS=1
            shift 
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ $# -lt 1 ]] ; then
    echo "target directory was not set"
    exit 2
fi

DIR="$1"

if [[ ! -d "$DIR" ]]; then
    echo "$DIR not found"
    exit 1
fi

checkHashAlgo
collectFiles
groupBySize
processDuplicates
printReport

exit 0

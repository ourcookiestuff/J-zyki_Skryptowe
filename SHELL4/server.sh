#!/bin/bash
#Jakub Dziurka

set -e

# wartości domyślne
PORT=6789

# parsowanie argumetnów (opcja -p)
while getopts "p:" opt; do
    case "$opt" in
        p) 
            PORT="$OPTARG" 
            ;;
        *)
            ;;
    esac
done

# sprawdzanie czy port jest dostępny
if lsof -i :"$PORT" >/dev/null 2>&1; then
    echo "Port ${PORT} is unavailable"
    exit 1
fi

HANDLER="./handler.sh"

# uruchomienie serwera
socat -u TCP-LISTEN:"$PORT",reuseaddr,fork SYSTEM:"bash '$HANDLER'" 2>/dev/null &
echo $! > server.pid

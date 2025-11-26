#!/bin/bash

COUNTER_FILE="./counter.txt"

# załadowanie pliku do przechowywania licznika
if [ -f "$COUNTER_FILE" ]; then
    COUNTER=$(cat "$COUNTER_FILE")
else 
    COUNTER=0
fi

read -r REQUEST || exit 0

case "$REQUEST" in
    "?")
        echo "$COUNTER"
        ;;
    "INC")
        COUNTER=$(( COUNTER += 1 ))
        echo "$COUNTER" > "$COUNTER_FILE"
        ;;
esac

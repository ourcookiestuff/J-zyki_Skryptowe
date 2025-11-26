#!/bin/bash
#Jakub Dziurka

PORT=6789

send_query() {
    echo "$1" | nc localhost "$PORT"
}

ARG=$1
case "$ARG" in
    "?")
        send_query "?"
        ;;
    "INC")
        send_query "INC"
        ;;
    "test1")
        send_query "?"
        send_query "INC"
        send_query "INC"
        send_query "?"
        send_query "INC"
        send_query "?"
        ;;
esac
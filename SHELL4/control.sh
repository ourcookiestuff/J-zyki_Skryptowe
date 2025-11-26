#!/bin/bash
#Jakub Dziurka

DEF_PORT=6789
SERVER="./server.sh"
PID_FILE="./server.pid"
CONFIG_FILE="$HOME/.config/server.conf"

# piorytet portów
get_port() {
    local port=$1

    # piorytet 1
    if [ -n "$port" ]; then
        echo "$port"
        return
    fi

    # piorytet 2
    if [ -f "$CONFIG_FILE" ]; then 
        cat "$CONFIG_FILE"
        return
    fi

    # piorytet 3
    echo "$DEF_PORT"
}

SERVER_COMMAND=$1
ARG_PORT=$2

case "$SERVER_COMMAND" in
    start)
        # czy serwer działa
        if [[ -f "$PID_FILE" ]]; then
            pid=$(cat "$PID_FILE")
            if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null 2>&1; then
                # już działa
                exit 0
            else
                # stary plik PID — usuń
                rm -f "$PID_FILE"
            fi
        fi

        TARGET_PORT=$(get_port "$ARG_PORT")

        # start serwera
        bash "$SERVER" -p "$TARGET_PORT"
        ;;
    stop)
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            if ps -p "$pid" > /dev/null 2>&1; then
                kill "$pid"
                wait "$pid" 2>/dev/null
            fi
            rm -f "$PID_FILE"
        fi
        ;;
    restart)
        "$0" stop
        sleep 0.5
        "$0" start "$ARG_PORT" 
        ;;
    status)
        if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1; then
            cat "$PID_FILE"
        fi
        ;;
esac
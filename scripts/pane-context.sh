#!/usr/bin/env bash

TTY="$1"

[ -z "$TTY" ] && exit 0

TTY="${TTY#/dev/}"

# ============================================================
# DOCKER LOCAL
# ============================================================

DOCKER_CMD="$(
    ps -t "$TTY" -o args= 2>/dev/null |
    grep -E 'docker[[:space:]]+(exec|attach)[[:space:]]' |
    grep -v grep |
    head -n1
)"

if [ -n "$DOCKER_CMD" ]; then

    NAME="$(
        echo "$DOCKER_CMD" |
        sed -nE 's/.*docker[[:space:]]+(exec|attach)[[:space:]]+(-[^ ]+[[:space:]]+)*([^ ]+).*/\3/p'
    )"

    if [ -n "$NAME" ]; then

        REAL="$(
            docker inspect \
                --format '{{.Name}}' \
                "$NAME" 2>/dev/null |
            sed 's#^/##'
        )"

        if [ -n "$REAL" ]; then
            printf ' | Docker: %s' "$REAL"
            exit 0
        fi
    fi
fi


# ============================================================
# SSH
# ============================================================

SSH_CMD="$(
    ps -t "$TTY" -o args= 2>/dev/null |
    awk '
        /^ssh / ||
        /\/ssh / {
            print
            exit
        }
    '
)"

[ -z "$SSH_CMD" ] && exit 0

SSH_ARGS="$(
    echo "$SSH_CMD" |
    sed -E 's#^.*(^|/)(ssh)[[:space:]]+##'
)"

set -- $SSH_ARGS

HOST=""

while [ "$#" -gt 0 ]; do

    case "$1" in

        -4|-6|-A|-a|-C|-f|-G|-g|-K|-k|-M|-N|-n|-q|-s|-T|-t|-V|-v|-X|-x|-Y|-y)
            shift
            ;;

        -B|-b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-P|-p|-Q|-R|-S|-W|-w)
            shift 2
            ;;

        -[BbCcDdEeFfIiJjLlMmOoPpQqRrSsWw]*)
            shift
            ;;

        -*)
            shift
            ;;

        *)
            HOST="$1"
            break
            ;;
    esac

done

[ -z "$HOST" ] && exit 0

printf ' | SSH: %s' "$HOST"
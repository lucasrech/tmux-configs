#!/usr/bin/env bash

TTY="$1"

[ -z "$TTY" ] && exit 0

TTY="${TTY#/dev/}"

CMD="$(
    ps -t "$TTY" -o args= 2>/dev/null |
    grep -E 'docker[[:space:]]+(exec|attach)[[:space:]]' |
    grep -v grep |
    head -n1
)"

[ -z "$CMD" ] && exit 0

NAME="$(
    echo "$CMD" |
    sed -nE 's/.*docker[[:space:]]+(exec|attach)[[:space:]]+(-[^ ]+[[:space:]]+)*([^ ]+).*/\3/p'
)"

[ -z "$NAME" ] && exit 0

REAL="$(
    docker inspect --format '{{.Name}}' "$NAME" 2>/dev/null |
    sed 's#^/##'
)"

[ -n "$REAL" ] && printf 'Docker: %s' "$REAL"
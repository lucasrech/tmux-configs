#!/usr/bin/env bash
if ! command -v spotatui >/dev/null 2>&1; then
    printf '\n  spotatui não está instalado.\n'
    printf '  Para instalar: cargo install spotatui\n\n'
    printf '  Pressione qualquer tecla para fechar...\n'
    read -r -n1
    exit 127
fi

spotatui
code=$?

if [ "$code" -ne 0 ]; then
    printf '\n  spotatui encerrou com código %d\n\n' "$code"
    log=$(ls -t /tmp/spotatui_logs/ 2>/dev/null | head -1)
    [ -n "$log" ] && printf '  Log: /tmp/spotatui_logs/%s\n\n' "$log"
    printf '  Pressione qualquer tecla para fechar...\n'
    read -r -n1
fi

exit "$code"

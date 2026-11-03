#!/usr/bin/env bash
if ! command -v spotatui >/dev/null 2>&1; then
    printf '\n  spotatui não está instalado.\n'
    printf '  Para instalar: cargo install spotatui\n\n'
    printf '  Pressione qualquer tecla para fechar...\n'
    read -r -n1
    exit 0
fi
exec spotatui

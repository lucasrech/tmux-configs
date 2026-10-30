#!/usr/bin/env bash

if ! command -v spotatui &>/dev/null; then
    printf '\n  spotatui não está instalado.\n\n'
    printf '  Para instalar:\n'
    printf '    cargo install spotatui\n'
    printf '  ou consulte: https://github.com/jlucasnsilva/spotatui\n\n'
    printf '  Pressione qualquer tecla para fechar...\n'
    read -r -n1
    exit 0
fi

exec spotatui

#/usr/bin/env bash

__display_progress() {
    if [ -z "$1" ]; then
        return
    fi
    if [ -z "$2" ]; then
        return
    fi
    local total=$1
    local i=$2
    ((percent = i * 100 / total))
    ((done = percent * 50 / 100))
    ((left = 50 - done))
    local _fill=$(printf "%${done}s")
    local _empty=''
    if [ $left -ne 0 ]; then
        ((left = left - 1))
        _empty=$(printf ">%${left}s")
    fi

    printf "\r${percent}%% [${_fill// /=}${_empty}] ${i}/${total} command(s)"
    if [ $i -eq $total ]; then
        echo
    fi
}

__generate_console_completion_cache_file() {
    if [ -z "$(console -V 2>&1)" ]; then
        return
    fi

    local dir="$(pwd)"
    if [ ! -d "$dir/.console" ]; then
        mkdir "$dir/.console"
    fi
    if [ ! -d "$dir/.console/options" ]; then
        mkdir "$dir/.console/options"
    fi
    local commands_list_filepath="$dir/.console/commands"
    console list --raw  | awk '{print $1}'>"$commands_list_filepath"
    console -h --raw  | grep -o "\-\-[^\=\ ]\{1,\}">"$dir/.console/options/default_console_options"
    line_number=$(wc <"$commands_list_filepath" -l)
    declare -i i=0
    while IFS= read -r cmd; do
        if [ ! -d "$dir/.console/options/$cmd" ]; then
            mkdir "$dir/.console/options/$cmd"
        fi
        ((i = i + 1))
        console "$cmd" -h --raw  | grep -o "\-\-[^\=\ ]\{1,\}">"$dir/.console/options/$cmd/options"
        __display_progress $line_number $i
    done <"$commands_list_filepath"
}

__console_main() {
    if [ -z "$(console -V 2>&1)" ]; then
        return
    fi
    local dir="$(pwd)"
    if [ ! -d "$dir/.console" ] || [ ! -f "$dir/.console/commands" ]; then
        return
    fi

    local cur prev subcmd suggestions cmd_str
    _get_comp_words_by_ref -n : cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    subcmd="${COMP_WORDS[1]}"
    suggestions="$(cat "$dir/.console/commands")"
    case "$cur" in
        --*)
            local option_file="$dir/.console/options/default_console_options"
            if [ -n "$subcmd" ] && [ -n "$(grep "$subcmd" "$dir/.console/commands")" ] && [ -f "$dir/.console/options/$subcmd/options" ]; then
                option_file="$dir/.console/options/$subcmd/options"
            fi
            suggestions="$(cat "$option_file")"
        ;;
    esac

    COMPREPLY=($(compgen -W "${suggestions}" -- ${cur}) )
    __ltrim_colon_completions "$cur"
    return 0
}

complete -F __console_main -o default console

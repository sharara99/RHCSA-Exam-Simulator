#!/bin/bash
# Bash completion for nmcli

_nmcli() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Main nmcli objects
    local objects="general networking radio connection device agent monitor"
    
    # Connection subcommands
    local con_commands="show up down add modify edit clone delete monitor reload load"
    local con_options="id uuid type ifname autoconnect save"
    
    # Device subcommands
    local dev_commands="status show set connect disconnect delete reapply modify wifi wimax"
    
    # General subcommands
    local gen_commands="status hostname permissions logging"
    
    case "${COMP_WORDS[1]}" in
        g|general|gen)
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=($(compgen -W "${gen_commands}" -- "${cur}"))
            fi
            ;;
        n|networking|net)
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=($(compgen -W "on off connectivity" -- "${cur}"))
            fi
            ;;
        c|connection|con)
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=($(compgen -W "${con_commands}" -- "${cur}"))
            elif [ $COMP_CWORD -eq 3 ] && [[ "${prev}" == "show" || "${prev}" == "up" || "${prev}" == "down" || "${prev}" == "modify" || "${prev}" == "edit" || "${prev}" == "delete" || "${prev}" == "reload" ]]; then
                # Try to get connection names/ids
                local connections=$(nmcli -t -f NAME connection show 2>/dev/null)
                COMPREPLY=($(compgen -W "${connections}" -- "${cur}"))
            elif [ $COMP_CWORD -eq 3 ] && [[ "${prev}" == "add" ]]; then
                COMPREPLY=($(compgen -W "type ifname con-name autoconnect save" -- "${cur}"))
            fi
            ;;
        d|device|dev)
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=($(compgen -W "${dev_commands}" -- "${cur}"))
            elif [ $COMP_CWORD -eq 3 ] && [[ "${prev}" == "show" || "${prev}" == "set" || "${prev}" == "connect" || "${prev}" == "disconnect" || "${prev}" == "delete" || "${prev}" == "reapply" || "${prev}" == "modify" ]]; then
                local devices=$(nmcli -t -f DEVICE device status 2>/dev/null | cut -d: -f1)
                COMPREPLY=($(compgen -W "${devices}" -- "${cur}"))
            fi
            ;;
        r|radio|rad)
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=($(compgen -W "wifi wwan all" -- "${cur}"))
            fi
            ;;
        *)
            if [ $COMP_CWORD -eq 1 ]; then
                COMPREPLY=($(compgen -W "${objects}" -- "${cur}"))
            fi
            ;;
    esac
    
    return 0
}

complete -F _nmcli nmcli

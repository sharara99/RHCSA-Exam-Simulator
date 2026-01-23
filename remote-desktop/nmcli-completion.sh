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
            elif [ $COMP_CWORD -ge 4 ] && [[ "${COMP_WORDS[2]}" == "modify" || "${COMP_WORDS[2]}" == "edit" ]]; then
                # Complete connection properties (ipv4.*, ipv6.*, connection.*, etc.)
                local ipv4_props="ipv4.method ipv4.addresses ipv4.gateway ipv4.dns ipv4.dns-search ipv4.dns-options ipv4.routes ipv4.route-metric ipv4.ignore-auto-routes ipv4.ignore-auto-dns ipv4.dhcp-client-id ipv4.dhcp-timeout ipv4.dhcp-send-hostname ipv4.dhcp-hostname ipv4.dhcp-hostname-flags ipv4.never-default ipv4.may-fail"
                local ipv6_props="ipv6.method ipv6.addresses ipv6.gateway ipv6.dns ipv6.dns-search ipv6.dns-options ipv6.routes ipv6.route-metric ipv6.ignore-auto-routes ipv6.ignore-auto-dns ipv6.never-default ipv6.may-fail ipv6.ip6-privacy"
                local connection_props="connection.id connection.uuid connection.type connection.interface-name connection.autoconnect connection.autoconnect-priority connection.timestamp connection.read-only connection.permissions connection.zone connection.master connection.slave-type connection.autoconnect-slaves connection.secondaries connection.gateway-ping-timeout"
                local ethernet_props="ethernet.port ethernet.speed ethernet.duplex ethernet.auto-negotiate ethernet.mac-address ethernet.cloned-mac-address ethernet.mac-address-blacklist ethernet.mtu ethernet.s390-subchannels ethernet.s390-nettype ethernet.s390-options ethernet.wake-on-lan ethernet.offload"
                
                # Check if we're completing ipv4.*
                if [[ "${cur}" == ipv4.* ]] || [[ "${cur}" == ipv4. ]]; then
                    COMPREPLY=($(compgen -W "${ipv4_props}" -- "${cur}"))
                # Check if we're completing ipv6.*
                elif [[ "${cur}" == ipv6.* ]] || [[ "${cur}" == ipv6. ]]; then
                    COMPREPLY=($(compgen -W "${ipv6_props}" -- "${cur}"))
                # Check if we're completing connection.*
                elif [[ "${cur}" == connection.* ]] || [[ "${cur}" == connection. ]]; then
                    COMPREPLY=($(compgen -W "${connection_props}" -- "${cur}"))
                # Check if we're completing ethernet.*
                elif [[ "${cur}" == ethernet.* ]] || [[ "${cur}" == ethernet. ]]; then
                    COMPREPLY=($(compgen -W "${ethernet_props}" -- "${cur}"))
                # Otherwise, show all common properties
                else
                    local all_props="${ipv4_props} ${ipv6_props} ${connection_props} ${ethernet_props}"
                    COMPREPLY=($(compgen -W "${all_props}" -- "${cur}"))
                fi
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

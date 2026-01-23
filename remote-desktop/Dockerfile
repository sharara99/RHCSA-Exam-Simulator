# Base Image
FROM nishanb/ck-x-simulator-vnc-base:v3

# Switch to root user for installations
USER 0

# Update and install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    openssh-server \
    ssh-client \
    telnet \
    nano \
    vim \
    curl \
    wget \
    xclip \
    network-manager \
    dbus \
    net-tools \
    iputils-ping \
    dnsutils \
    iproute2 \
    bash-completion \
    lvm2

#create candidate user with password "123"
RUN useradd -m candidate && echo "candidate:123" | chpasswd

# Create wire interface (dummy interface for exam networking questions)
# This will be managed by NetworkManager and is the only interface students can configure
RUN echo '#!/bin/bash\n\
# Create wire interface if it does not exist\n\
if ! ip link show wire >/dev/null 2>&1; then\n\
    ip link add wire type dummy 2>/dev/null || true\n\
    ip link set wire up 2>/dev/null || true\n\
fi\n\
' > /usr/local/bin/create-wire-interface.sh && \
    chmod +x /usr/local/bin/create-wire-interface.sh

# Configure SSH server
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
RUN ssh-keygen -A

#set hostname as terminal
RUN echo "terminal" > /etc/hostname && \
    echo "export HOSTNAME=terminal" >> /headless/.bashrc && \
    echo "export HOSTNAME=terminal" >> /root/.bashrc && \
    echo "# Function to get hostname from /etc/hostname for prompt" >> /root/.bashrc && \
    echo "get_hostname() { cat /etc/hostname 2>/dev/null || echo terminal; }" >> /root/.bashrc && \
    echo "# Update PS1 to use hostname from /etc/hostname" >> /root/.bashrc && \
    echo "if [ -z \"\$PS1_HOSTNAME\" ]; then" >> /root/.bashrc && \
    echo "  export PS1_HOSTNAME=\"\$(get_hostname)\"" >> /root/.bashrc && \
    echo "  export PS1=\"\\[\\e]0;\\u@\\h: \\w\\a\\]\\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;32m\\]\\u@\\[\\033[01;33m\\]\\\$PS1_HOSTNAME\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]# \"" >> /root/.bashrc && \
    echo "fi" >> /root/.bashrc
#set terminal to bash
RUN echo "export TERM=xterm" >> /headless/.bashrc

# Keep root as default user (removed candidate user switch)

#disable asking for ssh host verification
RUN mkdir -p /home/candidate/.ssh
RUN touch /home/candidate/.ssh/config
RUN echo "StrictHostKeyChecking no" >> /home/candidate/.ssh/config
RUN echo "UserKnownHostsFile /dev/null" >> /home/candidate/.ssh/config

# Set up passwordless SSH for candidate user (SSH to localhost/node1)
RUN ssh-keygen -t rsa -b 2048 -f /home/candidate/.ssh/id_rsa -N "" -q
RUN cat /home/candidate/.ssh/id_rsa.pub >> /home/candidate/.ssh/authorized_keys
RUN chmod 600 /home/candidate/.ssh/authorized_keys
RUN chmod 700 /home/candidate/.ssh
RUN chown -R candidate:candidate /home/candidate/.ssh

# Enable bash completion for root user (only for interactive shells)
RUN echo "# Enable bash completion" >> /root/.bashrc && \
    echo "if [ -n \"\$PS1\" ]; then" >> /root/.bashrc && \
    echo "  [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion 2>/dev/null || true" >> /root/.bashrc && \
    echo "  # Load all completion files including hostnamectl and nmcli" >> /root/.bashrc && \
    echo "  if [ -d /usr/share/bash-completion/completions ]; then" >> /root/.bashrc && \
    echo "    for file in /usr/share/bash-completion/completions/*; do" >> /root/.bashrc && \
    echo "      [ -r \"\$file\" ] && source \"\$file\" 2>/dev/null || true" >> /root/.bashrc && \
    echo "    done" >> /root/.bashrc && \
    echo "  fi" >> /root/.bashrc && \
    echo "fi" >> /root/.bashrc


# Create hostnamectl wrapper (since systemd is not available in container)
# This allows hostnamectl commands to work for exam practice
# /usr/local/bin is typically earlier in PATH than /usr/bin, so this will override system hostnamectl
RUN cat > /usr/local/bin/hostnamectl <<'EOF' && chmod +x /usr/local/bin/hostnamectl
#!/bin/bash
# Wrapper for hostnamectl to work without systemd

case "$1" in
    set-hostname)
        if [ -z "$2" ]; then
            echo "Usage: hostnamectl set-hostname NAME" >&2
            exit 1
        fi
        NEW_HOSTNAME="$2"
        # Set hostname using traditional method
        echo "$NEW_HOSTNAME" > /etc/hostname
        # Try to set hostname (may not work in containers, but /etc/hostname is what matters)
        hostname "$NEW_HOSTNAME" 2>/dev/null || true
        # Also try using sysctl (works in some container environments)
        sysctl -w kernel.hostname="$NEW_HOSTNAME" 2>/dev/null || true
        # Update /etc/hosts if needed
        if ! grep -q "^127.0.0.1.*$NEW_HOSTNAME" /etc/hosts 2>/dev/null; then
            # Remove old hostname entries for 127.0.0.1 (preserve other entries)
            OLD_HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "")
            if [ -n "$OLD_HOSTNAME" ] && [ "$OLD_HOSTNAME" != "$NEW_HOSTNAME" ]; then
                sed -i "/^127.0.0.1/s/\s\+$OLD_HOSTNAME\b//g" /etc/hosts 2>/dev/null || true
            fi
            # Add new hostname to 127.0.0.1 line
            if grep -q "^127.0.0.1" /etc/hosts; then
                sed -i "s/^127.0.0.1\t/127.0.0.1\t$NEW_HOSTNAME /" /etc/hosts 2>/dev/null || \
                sed -i "s/^127.0.0.1 /127.0.0.1 $NEW_HOSTNAME /" /etc/hosts 2>/dev/null || true
            fi
            if ! grep -q "^127.0.0.1.*$NEW_HOSTNAME" /etc/hosts 2>/dev/null; then
                echo "127.0.0.1	$NEW_HOSTNAME" >> /etc/hosts
            fi
        fi
        # Export HOSTNAME for current session and update prompt
        export HOSTNAME="$NEW_HOSTNAME"
        export PS1_HOSTNAME="$NEW_HOSTNAME"
        # Update PS1 to reflect new hostname (for current session)
        if [ -n "$PS1" ]; then
            # Update PS1_HOSTNAME and rebuild PS1
            export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\[\033[01;33m\]$NEW_HOSTNAME\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# "
        fi
        echo "Hostname set to: $NEW_HOSTNAME"
        ;;
    status|show)
        CURRENT_HOSTNAME=$(cat /etc/hostname 2>/dev/null || hostname 2>/dev/null || echo "n/a")
        echo "   Static hostname: $CURRENT_HOSTNAME"
        echo "         Icon name: computer"
        if [ -f /etc/machine-id ]; then
            echo "        Machine ID: $(cat /etc/machine-id)"
        else
            echo "        Machine ID: not available"
        fi
        if [ -f /proc/sys/kernel/random/boot_id ]; then
            echo "           Boot ID: $(cat /proc/sys/kernel/random/boot_id)"
        else
            echo "           Boot ID: not available"
        fi
        if command -v lsb_release >/dev/null 2>&1; then
            echo "  Operating System: $(lsb_release -ds 2>/dev/null || echo 'Linux')"
        else
            echo "  Operating System: Linux"
        fi
        echo "            Kernel: $(uname -r)"
        echo "      Architecture: $(uname -m)"
        ;;
    *)
        echo "hostnamectl: unknown command '$1'" >&2
        echo "Usage: hostnamectl {set-hostname NAME|status|show}" >&2
        exit 1
        ;;
esac
EOF

# Create bash completion for hostnamectl
RUN mkdir -p /usr/share/bash-completion/completions && \
    cat > /usr/share/bash-completion/completions/hostnamectl <<'EOF' && \
    chmod 644 /usr/share/bash-completion/completions/hostnamectl
_hostnamectl()
{
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # If previous word is set-hostname, complete with filenames (for hostname)
    if [[ "$prev" == "set-hostname" ]]; then
        COMPREPLY=($(compgen -f -- "$cur"))
        return 0
    fi
    
    # Otherwise, complete with subcommands (handles partial matches like "set-")
    COMPREPLY=($(compgen -W "set-hostname status show" -- "$cur"))
    return 0
}
complete -F _hostnamectl hostnamectl
EOF

# Create nmcli wrapper to filter out eth0 from device status (only show wire)
# This wrapper preserves autocompletion functionality and auto-applies wire config
RUN cat > /usr/local/bin/nmcli <<'EOF' && chmod +x /usr/local/bin/nmcli
#!/bin/bash
# Wrapper for nmcli to filter out eth0 from device status output
# Only wire interface should be visible and configurable
# Automatically applies IP configuration to wire interface after modify

# Check if this is being called for completion (bash completion sets COMP_LINE, COMP_POINT, etc.)
if [ -n "$COMP_LINE" ] || [ -n "$COMP_WORDS" ]; then
    # For completion, always use real nmcli but filter device status results
    if [ "$1" = "device" ] && [ "$2" = "status" ]; then
        /usr/bin/nmcli "$@" 2>&1 | grep -v -E "^\s*(eth0|lo)\s+"
    else
        /usr/bin/nmcli "$@"
    fi
elif [ "$1" = "connection" ] && [ "$2" = "modify" ] && [ "$3" = "wire" ]; then
    # Modify wire connection and automatically apply IP to interface
    /usr/bin/nmcli "$@"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        # Auto-apply the configuration to the wire interface
        export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
        # Get the IP configuration from the connection
        ipv4_addr=$(/usr/bin/nmcli -t -f ipv4.addresses connection show wire 2>/dev/null | cut -d: -f2)
        ipv4_gw=$(/usr/bin/nmcli -t -f ipv4.gateway connection show wire 2>/dev/null | cut -d: -f2)
        ipv4_method=$(/usr/bin/nmcli -t -f ipv4.method connection show wire 2>/dev/null | cut -d: -f2)
        
        # Apply IP if addresses are set (works even if method is auto)
        if [ -n "$ipv4_addr" ]; then
            # Remove any existing IP from wire interface first
            ip addr flush dev wire 2>/dev/null || true
            # Add the new IP address
            ip addr add $ipv4_addr dev wire 2>/dev/null || ip addr replace $ipv4_addr dev wire 2>/dev/null
            # Set gateway if specified
            if [ -n "$ipv4_gw" ]; then
                ip route del default dev wire 2>/dev/null || true
                ip route add default via $ipv4_gw dev wire 2>/dev/null || ip route replace default via $ipv4_gw dev wire 2>/dev/null
            fi
            echo "Applied IP configuration to wire interface: $ipv4_addr"
        fi
    fi
    exit $EXIT_CODE
elif [ "$1" = "device" ] && [ "$2" = "status" ]; then
    # Filter out eth0 and lo from device status, only show wire
    /usr/bin/nmcli "$@" 2>&1 | grep -v -E "^\s*(eth0|lo)\s+"
else
    # Pass through all other nmcli commands (including completion queries)
    /usr/bin/nmcli "$@"
fi
EOF

# Create hostname wrapper that reads from /etc/hostname (for exam compatibility)
RUN cat > /usr/local/bin/hostname <<'EOF' && chmod +x /usr/local/bin/hostname
#!/bin/bash
# Wrapper for hostname to show value from /etc/hostname instead of kernel hostname
# This makes it consistent with hostnamectl in container environments

if [ "$1" = "-f" ] || [ "$1" = "--fqdn" ]; then
    # Show FQDN if requested
    HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "")
    if [ -n "$HOSTNAME" ]; then
        echo "$HOSTNAME"
    else
        # Fallback to kernel hostname
        /bin/hostname "$@" 2>/dev/null || echo ""
    fi
elif [ "$1" = "-s" ] || [ "$1" = "--short" ]; then
    # Show short hostname
    HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "")
    if [ -n "$HOSTNAME" ]; then
        echo "${HOSTNAME%%.*}"
    else
        /bin/hostname "$@" 2>/dev/null || echo ""
    fi
elif [ "$1" = "-a" ] || [ "$1" = "--alias" ] || [ "$1" = "-i" ] || [ "$1" = "--ip-address" ] || [ "$1" = "-I" ] || [ "$1" = "--all-ip-addresses" ]; then
    # Pass through to real hostname for these options
    /bin/hostname "$@" 2>/dev/null
elif [ -z "$1" ]; then
    # No arguments - show hostname from /etc/hostname
    HOSTNAME=$(cat /etc/hostname 2>/dev/null)
    if [ -n "$HOSTNAME" ]; then
        echo "$HOSTNAME"
    else
        # Fallback to kernel hostname
        /bin/hostname 2>/dev/null || echo ""
    fi
else
    # Try to set hostname (may not work in containers, but try anyway)
    /bin/hostname "$@" 2>/dev/null || {
        # If setting fails, at least update /etc/hostname
        if [ "$1" != "-?" ] && [ "$1" != "--help" ]; then
            echo "$1" > /etc/hostname 2>/dev/null || true
        fi
        /bin/hostname "$@" 2>/dev/null || true
    }
fi
EOF

# Ensure completion is loaded - add to /etc/bash.bashrc for all users
RUN echo "" >> /etc/bash.bashrc && \
    echo "# Load bash completion for all interactive shells" >> /etc/bash.bashrc && \
    echo "if [ -f /usr/share/bash-completion/bash_completion ] && ! shopt -oq posix; then" >> /etc/bash.bashrc && \
    echo "  source /usr/share/bash-completion/bash_completion 2>/dev/null" >> /etc/bash.bashrc && \
    echo "  [ -f /usr/share/bash-completion/completions/hostnamectl ] && source /usr/share/bash-completion/completions/hostnamectl 2>/dev/null" >> /etc/bash.bashrc && \
    echo "fi" >> /etc/bash.bashrc

# Also ensure it's in root's .bashrc as backup (same as hostnamectl)
RUN echo "" >> /root/.bashrc && \
    echo "# Force load bash completion, hostnamectl and nmcli completion" >> /root/.bashrc && \
    echo "if [ -f /usr/share/bash-completion/bash_completion ] && ! shopt -oq posix; then" >> /root/.bashrc && \
    echo "  source /usr/share/bash-completion/bash_completion 2>/dev/null" >> /root/.bashrc && \
    echo "  [ -f /usr/share/bash-completion/completions/hostnamectl ] && source /usr/share/bash-completion/completions/hostnamectl 2>/dev/null" >> /root/.bashrc && \
    echo "  [ -f /usr/share/bash-completion/completions/nmcli ] && source /usr/share/bash-completion/completions/nmcli 2>/dev/null" >> /root/.bashrc && \
    echo "fi" >> /root/.bashrc && \
    echo "" >> /root/.bashrc && \
    echo "# Explicitly load nmcli completion (same as hostnamectl)" >> /root/.bashrc && \
    echo "[ -f /usr/share/bash-completion/completions/nmcli ] && source /usr/share/bash-completion/completions/nmcli 2>/dev/null || true" >> /root/.bashrc

# Copy startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Copy and install nmcli completion script to same location as hostnamectl
COPY nmcli-completion.sh /usr/share/bash-completion/completions/nmcli
RUN chmod 644 /usr/share/bash-completion/completions/nmcli

COPY agent.py /tmp/agent.py

RUN sed -i '/### every exit != 0 fails the script/a /usr/local/bin/startup.sh' /dockerstartup/vnc_startup.sh
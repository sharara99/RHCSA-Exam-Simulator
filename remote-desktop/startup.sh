#!/bin/bash

# Log startup
echo "=========================================="
echo "RHCSA Exam Environment Pre-Configuration"
echo "=========================================="
echo "Starting RHCSA VNC service at $(date)"
echo ""
echo "Pre-configured for exam questions:"
echo "  - Network interface: 'wire' (for Q1 networking)"
echo "  - Default user: root"
echo "  - Hostname resolution: node1, classroom.example.com"
echo ""
echo "Note: For node2 questions (Q17-Q22), the following should be pre-configured:"
echo "  - Volume group 'vg' with logical volume 'lv' (for Q19 - resize to 300MB)"
echo "    Example: vgcreate vg /dev/vdb1 && lvcreate -L 76M -n lv vg"
echo "  - Volume group 'datastore' (for Q21 - create database LV with 50 PEs of 16MB)"
echo "    Example: vgcreate -s 16M datastore /dev/vdb3"
echo "  - Disk space for swap partition (Q20 - 715MB swap on /dev/vdb2)"
echo "  - Extended partitions if needed for multiple partitions"
echo ""
echo "Pre-configured components:"
echo "  ✓ Network interface 'wire' (dummy interface)"
echo "  ✓ User 'alth' (for container questions Q12, Q13)"
echo "  ✓ Directories: /root/locatedfiles, /opt/files, /opt/processed, /mnt/database"
echo "  ✓ LVM2 tools installed"
echo "=========================================="
echo ""

# Configure for root user (default user)
echo "echo 'Use Ctrl + Shift + C for copying and Ctrl + Shift + V for pasting'" >> /root/.bashrc
echo "alias kubectl='echo \"kubectl is not available in this RHCSA environment\"'" >> /root/.bashrc

# Add alias for nmctl -> nmcli (common typo)
echo "alias nmctl='nmcli'" >> /root/.bashrc

# Enable bash completion for root (only for interactive shells)
if [ -f /usr/share/bash-completion/bash_completion ]; then
    echo "# Enable bash completion" >> /root/.bashrc
    echo "if [ -n \"\$PS1\" ]; then" >> /root/.bashrc
    echo "  source /usr/share/bash-completion/bash_completion 2>/dev/null || true" >> /root/.bashrc
    echo "fi" >> /root/.bashrc
fi

# Enable nmcli completion for root
if [ -f /etc/bash_completion.d/nmcli ]; then
    echo "if [ -n \"\$PS1\" ]; then" >> /root/.bashrc
    echo "  source /etc/bash_completion.d/nmcli 2>/dev/null || true" >> /root/.bashrc
    echo "fi" >> /root/.bashrc
fi

# Enable systemd completions (hostnamectl, systemctl, timedatectl, etc.)
if [ -d /usr/share/bash-completion/completions ]; then
    echo "# Load systemd and other completions" >> /root/.bashrc
    echo "if [ -n \"\$PS1\" ]; then" >> /root/.bashrc
    echo "  # Load bash completion first" >> /root/.bashrc
    echo "  [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion 2>/dev/null || true" >> /root/.bashrc
    echo "  # Load all completion files including hostnamectl" >> /root/.bashrc
    echo "  for file in /usr/share/bash-completion/completions/*; do" >> /root/.bashrc
    echo "    [ -r \"\$file\" ] && source \"\$file\" 2>/dev/null || true" >> /root/.bashrc
    echo "  done" >> /root/.bashrc
    echo "fi" >> /root/.bashrc
fi

# Ensure bash is interactive for completion to work
echo "set completion-ignore-case on" >> /root/.inputrc
echo "set show-all-if-ambiguous on" >> /root/.inputrc
echo "set show-all-if-unmodified on" >> /root/.inputrc

# Ensure hostnamectl completion is loaded (add at end to override any issues)
echo "" >> /root/.bashrc
echo "# Force load hostnamectl completion" >> /root/.bashrc
echo "if [ -f /usr/share/bash-completion/bash_completion ]; then" >> /root/.bashrc
echo "    source /usr/share/bash-completion/bash_completion 2>/dev/null || true" >> /root/.bashrc
echo "    [ -f /usr/share/bash-completion/completions/hostnamectl ] && source /usr/share/bash-completion/completions/hostnamectl 2>/dev/null || true" >> /root/.bashrc
echo "fi" >> /root/.bashrc

# Ensure hostnamectl wrapper exists (created in Dockerfile, but verify it's executable)
if [ -f /usr/local/bin/hostnamectl ]; then
    chmod +x /usr/local/bin/hostnamectl
    echo "Verified hostnamectl wrapper is available"
fi

# Ensure node1 hostname resolution
if ! grep -q "node1" /etc/hosts; then
    echo "127.0.0.1 node1 node1.domain.example.com" >> /etc/hosts
fi
if ! grep -q "classroom.example.com" /etc/hosts; then
    echo "192.168.71.254 classroom.example.com" >> /etc/hosts
fi

# Create required directories for exam questions
mkdir -p /root/locatedfiles
mkdir -p /opt/files /opt/processed
mkdir -p /mnt/database
echo "Created exam directories: /root/locatedfiles, /opt/files, /opt/processed, /mnt/database"

# Create user 'alth' for container questions (Q12, Q13) if it doesn't exist
if ! id -u alth >/dev/null 2>&1; then
    useradd -m -s /bin/bash alth
    echo "alth:centtered" | chpasswd 2>/dev/null || true
    echo "Created user 'alth' for container questions"
fi

# Ensure SSH keys exist for root user (for passwordless login to node1)
if [ ! -f /root/.ssh/id_rsa ]; then
    mkdir -p /root/.ssh
    ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N "" -q
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
fi

# Start SSH server
if [ -f /usr/sbin/sshd ]; then
    /usr/sbin/sshd -D &
    echo "SSH server started"
fi

# Start D-Bus (required for NetworkManager and systemctl)
if [ -f /usr/bin/dbus-daemon ]; then
    # Clean up any existing D-Bus socket and pid file
    rm -f /var/run/dbus/system_bus_socket /var/run/dbus/pid
    mkdir -p /var/run/dbus
    
    # Start D-Bus system daemon in background (don't use --fork, run directly in background)
    dbus-daemon --system --nofork > /tmp/dbus.log 2>&1 &
    DBUS_PID=$!
    
    # Wait for D-Bus socket to be created
    for i in {1..15}; do
        if [ -S /var/run/dbus/system_bus_socket ]; then
            echo "D-Bus started successfully (socket exists, PID: $DBUS_PID)"
            break
        fi
        if ! kill -0 $DBUS_PID 2>/dev/null; then
            echo "D-Bus process died, trying to restart..."
            dbus-daemon --system --nofork > /tmp/dbus.log 2>&1 &
            DBUS_PID=$!
        fi
        sleep 1
    done
    
    # Verify D-Bus is actually running
    if [ -S /var/run/dbus/system_bus_socket ] && kill -0 $DBUS_PID 2>/dev/null; then
        echo "D-Bus is ready and running (PID: $DBUS_PID)"
    else
        echo "Warning: D-Bus may not be fully ready"
    fi
    
    # Set environment variable for D-Bus (for all users)
    export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
    echo "export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket" >> /root/.bashrc
    echo "export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket" >> /etc/environment
    
    # Also set it in the current shell environment for immediate use
    export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
fi

# Create permanent "wire" network interface (create it early, before NetworkManager)
# This ensures it exists and persists
create_wire_interface() {
    # Create dummy interface if it doesn't exist
    if ! ip link show wire >/dev/null 2>&1; then
        ip link add wire type dummy 2>/dev/null || true
        echo "Created network interface 'wire'"
    fi
    # Bring interface up
    ip link set wire up 2>/dev/null || true
}

# Create the wire interface immediately
create_wire_interface

# Start NetworkManager (required for nmcli) - start it after D-Bus is ready
if [ -f /usr/sbin/NetworkManager ]; then
    # Ensure NetworkManager can run in a container
    mkdir -p /var/lib/NetworkManager
    mkdir -p /run/NetworkManager
    
    # Configure NetworkManager to work in container without systemd
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/container.conf <<EOF
[main]
plugins=ifupdown,keyfile
[ifupdown]
managed=false
[keyfile]
unmanaged-devices=*
EOF
    
    # Wait for D-Bus to be ready before starting NetworkManager
    echo "Waiting for D-Bus to be ready..."
    for i in {1..15}; do
        if [ -S /var/run/dbus/system_bus_socket ]; then
            echo "D-Bus is ready, starting NetworkManager..."
            break
        fi
        sleep 1
    done
    
    # Start NetworkManager in background with proper environment
    (sleep 5 && \
     export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket && \
     NetworkManager --no-daemon > /tmp/nm.log 2>&1 & \
     NM_PID=$! && \
     sleep 3 && \
     if kill -0 $NM_PID 2>/dev/null; then
         echo "NetworkManager started (PID: $NM_PID)"
     else
         echo "NetworkManager may have failed to start, check /tmp/nm.log"
     fi) &
    
    # Create permanent NetworkManager connection for "wire" interface after NetworkManager starts
    (sleep 20 && \
     export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket && \
     # Ensure interface exists
     create_wire_interface && \
     # Wait a bit more for NetworkManager to be fully ready
     sleep 5 && \
     # Create NetworkManager connection if it doesn't exist
     if ! nmcli con show wire >/dev/null 2>&1; then
         nmcli connection add type ethernet ifname wire con-name wire autoconnect yes 2>/dev/null && \
         nmcli connection modify wire connection.autoconnect yes 2>/dev/null && \
         nmcli connection up wire 2>/dev/null && \
         echo "NetworkManager connection 'wire' created and activated"
     else
         # Ensure existing connection is set to autoconnect
         nmcli connection modify wire connection.autoconnect yes 2>/dev/null && \
         nmcli connection up wire 2>/dev/null && \
         echo "NetworkManager connection 'wire' configured for autoconnect"
     fi) &
fi

# Run in the background - don't block the main container startup
python3 /tmp/agent.py &

# Display final configuration summary
(sleep 20 && \
 echo "" && \
 echo "==========================================" && \
 echo "Configuration Summary:" && \
 echo "==========================================" && \
 echo "Network Interface 'wire':" && \
 (ip link show wire 2>/dev/null | head -2 || echo "  (checking...)") && \
 echo "" && \
 echo "NetworkManager Connections:" && \
 (nmcli con show 2>/dev/null | head -5 || echo "  (NetworkManager starting...)") && \
 echo "" && \
 echo "User 'alth':" && \
 (id alth 2>/dev/null && echo "  ✓ User 'alth' exists" || echo "  ✗ User 'alth' not found") && \
 echo "" && \
 echo "Directories:" && \
 (ls -ld /root/locatedfiles /opt/files /opt/processed /mnt/database 2>/dev/null | awk '{print "  ✓", $9}' || echo "  (checking...)") && \
 echo "" && \
 echo "LVM Tools:" && \
 (which pvcreate vgcreate lvcreate >/dev/null 2>&1 && echo "  ✓ LVM2 tools available" || echo "  ✗ LVM2 tools not found") && \
 echo "==========================================") &

exit 0 
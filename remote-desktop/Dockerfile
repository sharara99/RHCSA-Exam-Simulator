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

# Configure SSH server
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication no/' /etc/ssh/sshd_config
RUN ssh-keygen -A

#set hostname as terminal
RUN echo "export HOSTNAME=terminal" >> /headless/.bashrc
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

# Enable bash completion for root user
RUN echo "source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
RUN echo "source /etc/bash_completion.d/nmcli 2>/dev/null || true" >> /root/.bashrc


# Copy startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Copy and install nmcli completion script
COPY nmcli-completion.sh /etc/bash_completion.d/nmcli
RUN chmod +x /etc/bash_completion.d/nmcli

COPY agent.py /tmp/agent.py

RUN sed -i '/### every exit != 0 fails the script/a /usr/local/bin/startup.sh' /dockerstartup/vnc_startup.sh
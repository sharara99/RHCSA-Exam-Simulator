# Use a minimal Alpine Linux base image
FROM alpine:latest

# Install OpenSSH server and kubectl
RUN apk add --no-cache openssh openrc curl bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Set root password
RUN echo "root:password" | chpasswd

# Create candidate user and set password (kept for compatibility)
RUN adduser -D candidate && echo "candidate:password" | chpasswd

# Create .kube directory for root user
RUN mkdir -p /root/.kube && \
    chmod 755 /root/.kube

# Create .kube directory for candidate user (kept for compatibility)
RUN mkdir -p /home/candidate/.kube && \
    chown -R candidate:candidate /home/candidate/.kube && \
    chmod 755 /home/candidate/.kube

# Configure SSH for password authentication and allow root login
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config

# Copy the MOTD file
COPY motd /etc/motd

# Generate SSH host keys (necessary for SSH to work)
RUN ssh-keygen -A

# Expose SSH port
EXPOSE 22

# Start SSH daemon when the container runs
CMD ["/usr/sbin/sshd", "-D"]

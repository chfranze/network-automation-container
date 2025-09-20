# Stage 1: Build Python dependencies
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    libssl-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    ansible==9.5.1 \
    napalm \
    netmiko \
    paramiko \
    pyats \
    genie \
    ncclient \
    requests

# Stage 2: Final image
FROM python:3.11-slim

# Install core system tools and networking utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    sshpass \
    rsync \
    curl \
    wget \
    jq \
    netcat-openbsd \
    socat \
    iputils-ping \
    traceroute \
    mtr \
    vim \
    nano \
    less \
    git \
    unzip \
    sudo \
    tcpdump \
    nmap \
    iperf3 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform
ARG TERRAFORM_VERSION=1.9.7
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin/ \
 && rm terraform.zip

# Copy Python environment from builder
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin /usr/local/bin

# Create non-root user with sudo privileges
RUN useradd -m -s /bin/bash netuser \
 && echo 'netuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/netuser \
 && chmod 0440 /etc/sudoers.d/netuser

# Switch to non-root user
USER netuser
WORKDIR /home/netuser

# Install Ansible Cisco collections
RUN ansible-galaxy collection install --force \
    cisco.ios \
    cisco.iosxr \
    cisco.nxos \
    cisco.asa \
    cisco.dcnm \
    cisco.catalystcenter \
    cisco.catalystwan \
    cisco.cml \
    cisco.dnac \
    cisco.ise

# Copy and set permissions for entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

# Healthcheck to verify key tools
HEALTHCHECK --interval=30s --timeout=3s \
    CMD terraform --version && ansible --version && python --version || exit 1

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]

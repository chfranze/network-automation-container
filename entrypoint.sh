#!/bin/bash
# Enable colors and bash-completion
export PS1="\[\e[1;32m\]\u@\h:\w\$ \[\e[0m\]"
[[ -r /etc/bash_completion ]] && . /etc/bash_completion
shopt -s checkwinsize

# Prompt for first-time username if not set
if [ -z "$NETUSER" ]; then
    read -p "Enter your preferred username: " NETUSER
    export NETUSER
    echo "Username set to $NETUSER"
fi

# Require environment variables
required_vars=("TACACS_USER" "TACACS_KEY" "SOLARWINDS_USER" "SOLARWINDS_PASS")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        read -p "Enter value for $var: " val
        export $var="$val"
    fi
done

# Show environment summary
echo -e "\nEnvironment ready:"
for var in "${required_vars[@]}"; do
    echo " - $var=${!var}"
done

# Start interactive shell
exec /bin/bash

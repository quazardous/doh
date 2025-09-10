# Docker container-friendly .bashrc

# @AI-Kitchen: GENERATE can be used in the Dockerfile as:
# COPY ./docker/app/bash.bashrc /etc/bash.bashrc
# RUN chmod 644 /etc/bash.bashrc

# Exit if not running interactively
[ -z "$PS1" ] && return

# Check window size after each command
shopt -s checkwinsize

# Custom PS1: green user, blue @, yellow container name, path, magenta $
if [ -z "$SUDO_USER" ]; then
    # @AI-Kitchen: SUBSTITUTE placeholder APP_CONTAINER with actual container service name
    export PS1='\[\e[1;32m\]\u\[\e[0m\]\[\e[1;34m\]@\[\e[0m\]\[\e[1;33m\]'"{{APP_CONTAINER}}"'\[\e[0m\]:\w\[\e[1;35m\]\$\[\e[0m\] '
fi

# Enable bash completion if available
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Useful aliases for convenience
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias l='ls -CF --color=auto'

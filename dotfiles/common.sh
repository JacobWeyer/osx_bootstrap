# Common configuration for all shells

# Editor
export EDITOR="nano"
export VISUAL="nano"

# Language settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Less options
export LESS="-R"

# Colors for ls
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Disable Homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# GPG
export GPG_TTY=$(tty)

# Development directories
export DEV_DIR="$HOME/Developer"
export PROJECTS_DIR="$HOME/Projects"

# Utility aliases
# Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Utils
alias wget='wget -c'

# Override top with htop
alias top='htop'

# Untar
alias tgz='tar -xvfz'


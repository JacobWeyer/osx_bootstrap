##### Homebrew Formula: oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="eastwood"
plugins=(
    brew
    composer
    docker
    git
    gitflow
    github
    httpie
    node
    npm
    osx
    python
    vscode
    web-search
)
source $ZSH/oh-my-zsh.sh
source $HOME/.bash_profile
source $HOME/.alias/bash.sh
export PATH="/usr/local/sbin:$PATH"

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
source $HOME/.aliases/.alias
source $HOME/.aliases/.docker_alias
source $HOME/.aliases/.git_alias

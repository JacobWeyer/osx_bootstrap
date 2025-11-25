# Git configuration

# Aliases
alias g="git"
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gd="git diff"
alias gl="git log"
alias gp="git push"
alias gs="git status"
alias gst="git status"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias gpl="git pull"
alias gps="git push"
alias gpsu="git push -u"
alias gcl="git clone"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gcan="git commit --amend --no-edit"
alias gd="git diff"
alias gdc="git diff --cached"
alias gds="git diff --staged"
alias glog="git log --oneline --decorate --graph --all"
alias gloga="git log --oneline --decorate --graph --all --date=short"
alias gstash="git stash"
alias gstashp="git stash pop"
alias gstashl="git stash list"
alias greset="git reset"
alias greset-hard="git reset --hard"
alias gunstage="git reset HEAD --"
alias gfetch="git fetch"
alias gfetch-all="git fetch --all"
alias gmerge="git merge"
alias grebase="git rebase"
alias grebase-i="git rebase -i"
alias gtag="git tag"
alias gtag-l="git tag -l"
alias gremote="git remote"
alias gremote-v="git remote -v"
alias gsubmodule="git submodule"
alias gsubmodule-update="git submodule update --init --recursive"

# Functions
gac() {
  git add . && git commit -m "$1"
}

gacp() {
  git add . && git commit -m "$1" && git push
}

gnew() {
  git checkout -b "$1"
}

gdelete() {
  git branch -d "$1"
}

gforce-delete() {
  git branch -D "$1"
}

gupdate() {
  git fetch origin && git rebase origin/$(git branch --show-current)
}

gclean-branches() {
  git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

gundo() {
  git reset --soft HEAD~1
}

gamend() {
  git commit --amend --no-edit
}

gfixup() {
  git commit --fixup "$1" && git rebase -i --autosquash "$1"~1
}


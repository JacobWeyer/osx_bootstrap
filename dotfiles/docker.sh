# Docker configuration

# Aliases
alias d="docker"
alias dc="docker-compose"
alias dcu="docker-compose up"
alias dcud="docker-compose up -d"
alias dcd="docker-compose down"
alias dcb="docker-compose build"
alias dce="docker-compose exec"
alias dcl="docker-compose logs"
alias dcp="docker-compose ps"
alias dcr="docker-compose restart"
alias dcs="docker-compose stop"
alias dcrb="docker-compose up --build"
alias dcdv="docker-compose down -v"

# Get latest container ID
alias dl="docker ps -l -q"

# Get container process
alias dps="docker ps"

# Get process included stop container
alias dpa="docker ps -a"

# Get images
alias di="docker images"

# Get container IP
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# Run deamonized container, e.g., $dkd base /bin/echo hello
alias dkd="docker run -d -P"

# Run interactive container, e.g., $dki base /bin/bash
alias dki="docker run -i -t -P"

# Execute interactive container, e.g., $dex base /bin/bash
alias dex="docker exec -i -t"

# Functions
docker-clean() {
  docker system prune -a --volumes -f
}
alias dclean="docker-clean"

# Stop all containers
dstop() { docker stop $(docker ps -a -q); }

# Remove all containers
drm() { docker rm $(docker ps -a -q); }

# Stop and Remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

# Remove all images
dri() { docker rmi $(docker images -q); }

# Dockerfile build, e.g., $dbu tcnksm/test
dbu() { docker build -t=$1 .; }

# Show all alias related docker
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# Bash into running container
dbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }

docker-images-clean() {
  docker rmi $(docker images -q)
}
alias dimgclean="docker-images-clean"

docker-logs() {
  docker logs -f "$1"
}
alias dlogs="docker-logs"

docker-exec() {
  docker exec -it "$1" /bin/bash
}
alias dexec="docker-exec"

docker-exec-sh() {
  docker exec -it "$1" /bin/sh
}
alias dexecsh="docker-exec-sh"

# Environment variables
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-}"
export COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"


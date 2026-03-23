# -*- mode: sh -*-

# ── ls ────────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto --group-directories-first -X'   # colorized, dirs first, sorted by extension
alias l='ls -lh'                                           # long format with human-readable sizes
alias la='l -A'                                            # long format, including hidden files

# ── navigation ────────────────────────────────────────────────────────────────
alias c='clear'
alias q='exit'
alias b='builtin cd ..'          # go up one directory (bypasses any cd function overrides)
alias d=show_and_choose          # interactive directory picker (defined in functions.zsh)
alias 1='cd +1'                  # jump to the previous dir in the dir stack (see auto_pushd in options.zsh)

# ── info ──────────────────────────────────────────────────────────────────────
# Print current path, user, host, and shell in color
alias w='echo -e "$Blue ${"$(pwd)"/$HOME/~} ${Red}at ${Cyan}$(whoami)${Red}@${Yellow}$(hostname -s)$Red \
using $Yellow${0}$Purple ${DOT_PROMPT_CHAR:-$}${Rst}"'

# ── dotfiles ──────────────────────────────────────────────────────────────────
alias re='exec zsh'              # reload the shell (sources all config from scratch)
alias dot='la $(find ~ -maxdepth 1 -type l)'  # list all symlinks in home dir (i.e. installed dotfiles)
alias r='~/.dotfiles/install.sh'  # re-run the install script (e.g. after pulling updates)

# ── tmux ──────────────────────────────────────────────────────────────────────
alias t="~/.dotfiles/scripts/tmux/tmux-attach.sh"   # attach to existing session or create a new one

# ── search ────────────────────────────────────────────────────────────────────
alias ag='ag --path-to-ignore ~/.ignore --hidden'    # ag respects the shared ignore file and includes hidden files
alias agu='command ag --hidden -u -a'                # ag with no ignores (unrestricted, all files)

# ── archive ───────────────────────────────────────────────────────────────────
alias tarc='tar -zcvf file.tar.gz'   # create a gzipped tarball
alias tarx='tar -zxvf'               # extract a gzipped tarball

# ── vim ───────────────────────────────────────────────────────────────────────
alias v="vim"
alias vi='vim -u NONE -N'   # open vim with no config and nocompatible mode (bare vim, for debugging)

# ── git ───────────────────────────────────────────────────────────────────────
alias irebase='git rebase -i origin/main'   # interactive rebase from origin/main
alias grebase='git pull origin main --rebase'  # pull and rebase current branch on top of origin/main
alias g='git status -sb'     # short status with branch info
alias gv='git branch -vv'    # list branches with last commit and upstream tracking info
alias gb='git branch'
alias gco='git checkout'

# ── docker ────────────────────────────────────────────────────────────────────
docker_stop_all()          { docker stop $(docker ps -a -q); }
docker_remove_all()        { docker rm $(docker ps -a -q); }
docker_remove_empty_imgs() { docker images | awk '{print $2 " " $3}' | grep '^<none>' | awk '{print $2}' | xargs -I{} docker rmi {}; }
docker_build()             { docker build -t=$1 .; }
docker_bash()              { docker exec -it $(docker ps -aqf "name=$1") bash; }

alias dstop='docker_stop_all'                                             # stop all running containers
alias drm='docker_remove_all'                                             # remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'  # stop and remove all containers
alias drsc='docker rm $(docker ps -aq --filter status=exited)'            # remove all stopped containers
alias dri='docker rmi'                                                    # remove image(s)
alias drei='docker_remove_empty_imgs'                                     # remove untagged (<none>) images
alias dbu='docker_build'                                                  # build image from Dockerfile in current dir
alias dbash='docker_bash'                                                 # open bash in a named container
alias dl="docker ps -l -q"                                               # ID of the last-run container
alias dp='docker ps --format="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}"'  # formatted container list
alias dclean='drmf && drei'                                               # stop, remove all containers and dangling images
alias di="docker images"
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"   # get container IP address
alias dkd="docker run -d -P"     # run container detached with all ports published
alias dki="docker run -i -t -P"  # run container interactively with all ports published
alias drit='docker run --rm -i -t'  # run container interactively, remove when done
alias dex="docker exec -i -t"    # exec into a running container interactively

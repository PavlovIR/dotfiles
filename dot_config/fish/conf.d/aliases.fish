# eza
alias ls='eza --color --icons'
alias la='eza --color --icons -a -l'
alias ll='eza --color --icons -l'

# Wlclipboard
alias wlc="wl-copy"
alias wlp="wl-paste"
alias wlci="wl-copy  --type image/png"
alias wlpi="wl-paste --type image/png"

#git
alias ga='git add'
alias gap='ga --patch'
alias gb='git branch'
alias gba='gb --all'
alias gc='git commit'
alias gca='gc --amend --no-edit'
alias gce='gc --amend'
alias gco='git checkout'
alias gcl='git clone --recursive'
alias gd='git diff --output-indicator-new=" " --output-indicator-old=" "'
alias gds='gd --staged'
alias gi='git init'
alias gl='git log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'
alias gm='git merge'
alias gn='git checkout -b' # new branch
alias gp='git push'
alias gr='git reset'
alias gs='git status --short'
alias gu='git pull'

#systemd
# Aliases: systemd
alias sd='sudo systemctl'
alias sdu='systemctl --user'
alias jd='journalctl --no-pager'
alias sde='sudoedit'

# misc
function mk
    mkdir -p $argv; and cd $_
end

#Programs
alias rf='rm -rf'
alias py='python3'
alias ipy='ipython'
alias ping='ping -4A'
alias icat='kitten icat'
alias zat='zathura'
alias v='nvim'
alias rd='ripdrag -a'
alias cz='chezmoi'

alias sudo='sudo ' # allow aliases with sudo

# add personal config stuff
[[ -f ~/.zshenv ]] && source ~/.zshenv
[[ -f ~/.zaliases ]] && source ~/.zaliases
[[ -f ~/.zprivate ]] && source ~/.zprivate

# directory settings
setopt AUTO_PUSHD # automatically push old directory onto stack
setopt CHASE_LINKS # resolve symbolic links
setopt PUSHD_IGNORE_DUPS # don't push duplicates to stack
setopt PUSHD_TO_HOME # pushd with no args is equivalent to pushd $HOME

# completion settings
#TODO

# expansion and globbing settings
#TODO

# history settings
setopt INC_APPEND_HISTORY SHARE_HISTORY # dynamic shared history among zsh sessions
setopt EXTENDED_HISTORY # save timestamps in history
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS # discard old entries which are duplicates
setopt HIST_IGNORE_SPACE # ignore commands that begin with a space
setopt HIST_REDUCE_BLANKS # clean up whitespace in history
setopt HIST_VERIFY # load history entry into buffer before running

# initialization settings
#TODO

# I/O settings
setopt RM_STAR_WAIT # wait 10 seconds before confirming rm *
setopt CLOBBER # allow > to truncate existing files and >> to create files
setopt INTERACTIVE_COMMENTS # because i can
setopt HASH_CMDS # hash the locations of commands after first execution
setopt HASH_DIRS # hash all directories in path to command

# job control settings
setopt MONITOR # enable job control
setopt NOTIFY # report job status immediately
unsetopt BG_NICE # don't run background jobs at lower priority
setopt LONG_LIST_JOBS # show jobs list in long format
setopt AUTO_CONTINUE # disowned jobs are sent a CONT signal
setopt CHECK_JOBS # check background jobs before exiting
setopt HUP # send hup signal to jobs on exit

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
  colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
  eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
  eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
  (( count = $count + 1 ))
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export TERM=xterm-256color

PS1="$PR_CYAN%n$PR_WHITE@$PR_GREEN%U%m%u$PR_NO_COLOR:$PR_RED%10c$PR_NO_COLOR "
RPS1="$PR_LIGHT_YELLOW(%D{%m-%d %H:%M})$PR_NO_COLOR"
#LANGUAGE=
LC_ALL='en_US.UTF-8'
LANG='en_US.UTF-8'
LC_CTYPE=C

MUTT_EDITOR=vim

unsetopt ALL_EXPORT

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
autoload -U compinit
compinit

bindkey "^?" backward-delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey "^r" history-incremental-search-backward
bindkey ' ' magic-space    # also do history expansion on space
bindkey '^I' complete-word # complete on tab, leave expansion to _expand
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Completion Styles

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# command for process lists, the local web server details and host completion
# on processes completion complete all user processes
# zstyle ':completion:*:processes' command 'ps -au$USER'

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

#zstyle ':completion:*:processes' command 'ps ax -o pid,s,nice,stime,args | sed "/ps/d"'
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command'
#zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
#
#NEW completion:
# 1. All /etc/hosts hostnames are in autocomplete
# 2. If you have a comment in /etc/hosts like #%foobar.domain,
#    then foobar.domain will show up in autocomplete!
zstyle ':completion:*' hosts $(awk '/^[^#]/ {print $2 $3" "$4" "$5}' /etc/hosts | grep -v ip6- && grep "^#%" /etc/hosts | awk -F% '{print $2}')
# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'
# the same for old style completion
#fignore=(.o .c~ .old .pro)

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
        named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs avahi-autoipd\
        avahi backup messagebus beagleindex debian-tor dhcp dnsmasq fetchmail\
        firebird gnats haldaemon hplip irc klog list man cupsys postfix\
        proxy syslog www-data mldonkey sys snort bitlbee

# SSH Completion
zstyle ':completion:*:scp:*' tag-order \
   files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order \
   files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order \
   users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order \
   hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show

# initialize autoenv
[[ -f ~/.autoenv ]] && source ~/.autoenv

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

if test -f ~/.rvm/scripts/rvm; then
  [ "$(type rvm)" = "rvm is a function" ] || source ~/.rvm/scripts/rvm
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# git aliases
alias g='git'

# history alias
alias h='history'

# misc
alias fucking='sudo'

# kubernetes
alias k='kubectl'
alias docc='docker-compose'
export EDITOR=vim

# pager fixes
# X - dont clear less pager screen after exit
# F - automatically close if fits on screen
# R - show color
export LESS="-XFR"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTFILE=~/.zsh_history
# append to the history file, don't overwrite it
setopt APPEND_HISTORY

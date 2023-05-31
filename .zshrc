# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
bindkey '^R' history-incremental-search-backward

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/lmingari/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# The 'ls' family (this assumes you use the GNU ls)
alias ls='ls --color=auto --group-directories-first'	# add colors 
alias ll='ls -hl'               # extra information
alias la='ls -hAl'		# show hidden files
alias lr='ls -hlR'		# recursive ls
alias lx='ls -hlXB'		# sort by extension
alias lk='ls -hlSr'		# sort by size
alias lt='ls -hltr'		# sort by date
alias dotgit='/usr/bin/git --git-dir=/home/lmingari/.cfg/ --work-tree=/home/lmingari'

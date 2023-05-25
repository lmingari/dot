#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
#PS1='\e[1;33m[\u@\h \W]\$ \e[m'

# The 'ls' family (this assumes you use the GNU ls)
alias ls='ls --color=auto --group-directories-first'	# add colors 
alias ll='ls -hl'               # extra information
alias la='ls -hAl'		# show hidden files
alias lr='ls -hlR'		# recursive ls
alias lx='ls -hlXB'		# sort by extension
alias lk='ls -hlSr'		# sort by size
alias lt='ls -hltr'		# sort by date
alias dotgit='/usr/bin/git --git-dir=/home/lmingari/.cfg/ --work-tree=/home/lmingari'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

alias ..='cd ..'
alias listen='netstat -tulnp'
alias home='cd /home/'
alias ports='netstat -nape --inet'
alias os='rpm -q centos-release'

alias sc='systemctl'
alias s-enable='systemctl enable'
alias s-disable='systemctl disable'
alias s-start='systemctl start'
alias s-stop='systemctl stop'
alias s-restart='systemctl restart'
alias s-status='systemctl status'

alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
# use prepare for install unar p7zip from epel-release
extract () {
	for archive in $*; do
		if [ -f $archive ] ; then
			case $archive in
				*.tar.bz2)   tar xvjf $archive    ;;
				*.tar.gz)    tar xvzf $archive    ;;
				*.bz2)       bunzip2 $archive     ;;
				*.rar)       unar $archive       ;;
				*.gz)        gunzip $archive      ;;
				*.tar)       tar xvf $archive     ;;
				*.tbz2)      tar xvjf $archive    ;;
				*.tgz)       tar xvzf $archive    ;;
				*.zip)       unzip $archive       ;;
				*.Z)         uncompress $archive  ;;
				*.7z)        7za x $archive        ;;
				*)           echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

alias myip4="whatsmyip4"
function whatsmyip4 (){
	curl -s "https://myip4.ir/";
}
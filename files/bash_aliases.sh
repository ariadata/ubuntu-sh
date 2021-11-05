#!/bin/sh
#### custom bash_aliases
echo 'extract () {
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
				*)           echo "do not know how to extract $archive..." ;;
			esac
		else
			echo "$archive is not a valid file!"
		fi
	done
}
alias sc="systemctl"
alias myip4="whatsmyip4"
function whatsmyip4 (){
	curl -s "https://myip4.ir/";
}
' >> ~/.bash_aliases
## end bash_aliases
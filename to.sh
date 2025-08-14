if [ $# -gt 0 ]
then
	cd "$1" && ls --group-directories-first -A --color=auto;
else
	cd ~ && ls --group-directories-first -A --color=auto
fi

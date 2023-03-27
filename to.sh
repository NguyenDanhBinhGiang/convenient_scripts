if [ $# -gt 0 ]
then
	cd "$1" && ls --group-directories-first -a;
else
	cd ~ && ls --group-directories-first -a
fi

if [ $# -gt 0 ]
then
	cd "$1" && ls --group-directories-first -A;
else
	cd ~ && ls --group-directories-first -A
fi

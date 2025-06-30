if [ $# -gt 0 ]
then
	touch $1 && chmod +x $1 && ls --group-directories-first -A;
else
	echo "Missing argument: file name"
fi

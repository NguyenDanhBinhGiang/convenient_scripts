if [[ -n "$1" ]]
then
	source ~/python_venv/"$1"/bin/activate
else
	echo "missing param: venv name"
fi

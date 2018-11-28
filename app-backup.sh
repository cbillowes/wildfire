#!/bin/bash
echo "Backup your files to a private .git repository."
echo "example: backup your notes and ssh keys (with caution)."
echo ""

function help {
	echo "usage: ./app-backup.sh "
	echo " -h | --help      : shows this menu"
	echo " -d | --directory : the directory you want to back up"
	echo " -o | --origin    : the .git remote origin [git@<host>:<path>.git]"
}
echo "example: ./app-backup.sh -d ~/.ssh -o git@41.79.76.169/srv/ssh.git "

if [ $# -eq 0 ]
then
	help
else

	POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
		key="$1"

		case $key in
		    -h|--help)
		    HELP=true
		    shift # past argument
		    shift # past value
		    ;;
	    	    -i|--init)
		    INIT=true
		    shift # past argument
		    shift # past value 
		    ;;
		    -d|--directory)
		    DIRECTORY="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -o|--origin)
		    ORIGIN="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    *)    # unknown option
		    POSITIONAL+=("$1") # save it in an array for later
		    shift # past argument
		    ;;
		esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters

	if [ "${HELP}" == "true" ]
	then
		help
	else
		cd ${DIRECTORY}
		if [ "${INIT}" == "true" ] ;
		then
			echo "Initialize .git repository."
			git init

			echo "Commit everything."
			git add .
			git commit -m "Initial commit"

			echo "Add ${ORIGIN} remote origin."
			git remote add origin ${ORIGIN}
		else
			echo "Commit everything."
			git add .
			git commit -m "Backup $(date +%s)"
		fi

		echo "Push to origin master."
		git push origin master
	fi

fi

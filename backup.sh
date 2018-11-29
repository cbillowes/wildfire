#!/bin/bash
echo "Automatic backup of a directory to git."
echo "NOTE! There are no checks for binaries and other files that should not belong in .git"
echo "Use with caution."
echo

function help {
	echo "usage:"
	echo " -h | --help     : shows this menu"
	echo " -d | --dir      : .git directory to backup"
	echo " -f | --filename : name of the backup script (it will be prefix with save-)"
	echo " -i | --init     : initialize a .git repository and create the automatic backup script"
	echo " -o | --origin   : origin to push to .git repository"
	echo " -c | --commit   : commit and push all files in directory"

	echo
	echo "examples:"
	echo
	echo "Create a backup script with a global executable to commit your files with one command."
	echo ".\\backup.sh -d ~/.ssh -f ssh -i -o http://git@\<HOST\>:/srv/git\<PROJECT>.git -c (add to immediately commit your files)"
	echo 

	echo "Commit your files using the global executable script previously created using this script."
	echo ".\\backup.sh -d ~/.ssh" -f ssh -c
	echo

}

if [ $# -eq 0 ]; then
	help
else
	POSITIONAL=()
	while [[ $# -gt 0 ]]
	do
		key="$1"
		case $key in
			-h|--help)
				HELP=true
				shift
				;;
			-d|--dir)
				DIRECTORY="$2"
				shift
				shift
				;;
			-f|--filename)
				FILENAME="$2"
				shift
				shift
				;;
			-i|--init)
				INIT=true
				shift
				;;
			-o|--origin)
				ORIGIN="$2"
				shift
				shift
				;;
			-c|--commit)
				COMMIT=true
				shift
				;;
			*)
				POSITIONAL+=("$1")
				shift
				;;
		esac
	done
	set -- "${POSITIONAL[@]}"

	if [ "${HELP}" == "true" ]; then
		help
	else
		if [ "${INIT}" != "true" ] && [ "${COMMIT}" != "true" ]; then
			echo "The script cannot be executed. You need to either initialize or commit your files, or both."
			echo
			help
		fi

		if [ "${INIT}" == "true" ]; then
			echo "Going to ${DIRECTORY}..."
			cd ${DIRECTORY}

			if [ -d .git ]; then
				echo ".git is already initialized"
			else
				echo "Initializing .git..."
				git init
			fi

			if [ "${ORIGIN}" ]; then
				echo "Adding ${ORIGIN} origin..."
				git remote add origin ${ORIGIN}
			fi

			if [ -f backup ]; then
				echo "automatic backup script already exists"
			else
				echo "Creating automatic backup script..."
				cat << EOF >> backup
#!/bin/bash

cd ${DIRECTORY}
git add .
git commit -m "Backup \$(date +%s)"
git push origin master
EOF
				echo "Making automatic backup script executable..."
				chmod +x backup

				echo "Creating a symlink..."
				sudo ln -s ${DIRECTORY}/backup /usr/local/bin/save-${FILENAME}
			fi
		fi


		if [ "${COMMIT}" == "true" ]; then
			echo "Backing up files using save-${FILENAME}"
			save-${FILENAME}
		fi
	fi
fi

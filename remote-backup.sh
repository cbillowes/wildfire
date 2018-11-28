#!/bin/bash
echo "Create a remote repository for private backups using .git."
echo "example: backup your notes and ssh keys (with caution)."

function help {
	echo "usage: ./remote-backup.sh"
	echo " -h | --help       : shows this menu"
	echo " -n | --new        : create the new git user and add its permissions"
	echo " -i | --init       : initialize a barebones git repository"
	echo " -c | --clean      : cleanup (removes) previous git repository"
	echo " -d | --directory  : the local directory"
	echo " -U | --user       : the user to login to the host"
	echo " -O | --host       : the host name or ip address"
	echo " -P | --path       : the path of the remote repository directory. eg. project.git"
	echo " -H | --home       : the user home directory"
}
echo "sample : ./remote-backup.sh -n -i -d ~/.ssh -U user -O 192.168.1.1 -P ssh.git -H /home/user"
echo

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
				shift
				;;
			-n|--new)
				NEW=true
				shift
				;;
			-i|--init)
				INIT=true
				shift
				;;
			-c|--clean)
				CLEAN=true
				shift
				;;
			-d|--directory)
				DIRECTORY="$2"
				shift
				shift
				;;
			-U|--user)
				USER="$2"
				shift
				shift
				;;
			-O|--host)
				HOST="$2"
				shift
				shift
				;;
			-P|-path)
				REMOTEPATH="$2"
				shift
				shift
				;;
			-H|--home)
				HOMEPATH="$2"
				shift
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
	
		if [ "${NEW}" == "true" ]; then
			echo "Connecting to ${USER}@${HOST}..."
			ssh ${USER}@${HOST} << EOF
				echo "Creating a git user for our remote repository..."
				sudo adduser git
				sudo usermod -aG git git

				echo "> Setting password..."
				echo "git" | passwd --stdin git

				echo "> Making the .ssh directory..."
				sudo -S mkdir -p /home/git/.ssh
				sudo -S chmod 700 /home/git/.ssh
				sudo -S cp ${HOMEPATH}/.ssh/authorized_keys /home/git/.ssh/authorized_keys

				echo "> Owning the .ssh directory..."
				sudo chown -R git:git /home/git/.ssh
				echo
EOF
		fi

		if [ "${INIT}" == "true" ]; then

			if [ "${CLEAN}" == "true" ]; then
				echo "Connecting to ${USER}@${HOST}..."
				ssh ${USER}@${HOST} << EOF
					echo "Cleaning up the prevous configuration..."
					sudo -S rm -rf /srv/git/${REMOTEPATH}
					echo
EOF
			fi

			echo "Connecting to ${USER}@${HOST}..."
			ssh ${USER}@${HOST} << EOF
				echo "Creating the remote barebones .git project..."
			
				echo "> Making the project directory..."
				sudo -S mkdir -p /srv/git/${REMOTEPATH}

				echo "> Initializing the .git project..."
				cd /srv/git/${REMOTEPATH}
				sudo -S git init --bare
				sudo chown -R git:git ../${REMOTEPATH}
				echo
EOF

			echo "Going to local ${DIRECTORY}..."
			cd ${DIRECTORY}

			echo "> Initializing git..." 
			git init

			echo "> Adding origin git@${HOST}:/srv/git/${REMOTEPATH}"
			git remote add origin git@${HOST}:/srv/git/${REMOTEPATH}

			echo "> Adding files..."
			git add .

			echo "> Committing files..."
			git commit -m "Initial commit"

			echo "> Pushing to origin..."
			git push -u origin master
		fi
		echo

	fi
fi

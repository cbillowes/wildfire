#!/bin/bash
echo "Customized configuration for new Fedora environment."
echo "usage: ./setup.sh"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
HEADING=$(tput setaf 3)
NORMAL=$(tput sgr0)

col=80 

function help {
	echo "-h | --help     : find out how to do cool stuff"
	echo "-u | --username : the username of the host you wish to go nuts on"
	echo "-o | --host     : the host you are actually going to go nuts on"
	echo "-p | --path     : the path of the user's home directory eg. /root or /home/user"
	echo "-j | --project  : the git project you want to configure eg. project.git"
}
echo
echo "example: ./setup.sh -u <USER> -o <HOSTNAME|HOST IP> -p /home/<USER> -j <PROJECT>.git"
echo "         ./setup.sh -u clarice -o 192.168.1.1 -p /home/clarice -j galaxy.git"

function print {
	printf "\n$(tput setaf 3)$1$(tput sgr0)\n"
}

function status {
	if [ $? -eq 0 ]; then
		printf '%s%*s%s\n' "$GREEN" $col "[OK]" "$NORMAL"
	else
		printf '%s%*s%s\n' "$RED" $col "[FAIL]" "$NORMAL"
	fi
}

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
				shift
				;;
			-u|--username)
				USERNAME="$2"
				shift
				shift
				;;
			-o|--host)
				HOST="$2"
				shift
				shift
				;;
			-p|--path)
				HOMEPATH="$2"
				shift
				shift
				;;
			-j|--project)
				PROJECT="$2"
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

	if [ "${HELP}" == "true" ]
	then
		help
	else
		print "Uploading oh my zsh installation file..."
		scp -P 22 oh-my-zsh.sh ${USERNAME}@${HOST}:${HOMEPATH}/oh-my-zsh.sh
		status

		print "Uploading sudoers file..."
		scp -P 22 sudoers ${USERNAME}@${HOST}:${HOMEPATH}/sudoers
		status

		print "Connecting to ${USERNAME}@${HOST}..."
		ssh ${USERNAME}@${HOST} << EOF
			echo "Sorting out some important files..."
			echo "> Creating copy of authorized keys..."
			cp ${HOMEPATH}/.ssh/authorized_keys ${HOMEPATH}/authorized_keys

			echo "> Owning sudoers file..."
			chown ${USERNAME}:${USERNAME} /${USERNAME}/sudoers

			echo "> Moving sudoers file..."
			mv /${USERNAME}/sudoers /etc/sudoers
				
			echo
			echo "Managing the package manager..."	
			echo "> Cleaning packages..."
			dnf clean packages

			echo "> Updating dnf..."
			dnf update -y

			echo "> Upgrading dnf..."
			dnf upgrade -y

			echo "> Installing some cool packages..."
			dnf install -y git vim zsh util-linux-user

			echo
			echo "Installing oh-my-zsh..."
			echo "> Cleaning up previous installations..."
			rm -rf ${HOMEPATH}/.oh-my-zsh
			rm -rf .zshrc

			echo "> Installing..."
			cd ${HOMEPATH}
			./oh-my-zsh.sh
			rm oh-my-zsh.sh
			
			echo
			echo "Spicing up the new shell..."

			echo "> Installing zsh-syntax-highlighting..."
			echo ">> Cleaning up previous installations..."
			rm -rf ${HOMEPATH}/custom/plugins/zsh-syntax-highlighting

			echo ">> Getting the plugin..."
			git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

			echo ">> Moving plugin..."
			mv zsh-syntax-highlighting .oh-my-zsh/custom/plugins

			echo "> Installing zsh-autosuggestions..."
			echo ">> Cleaning up previous installations..."
			rm -rf ${HOMEPATH}/custom/plugins/zsh-autosuggestions

			echo ">> Getting the plugin..."
			git clone https://github.com/zsh-users/zsh-autosuggestions.git

			echo ">> Moving plugin..."
			mv zsh-autosuggestions .oh-my-zsh/custom/plugins/zsh-autosuggestions

			echo
			echo "Creating a git user for our remote repository..."
			echo "> Adding user..."
			sudo adduser git
			sudo usermod -aG git git

			echo "> Setting password..."
			echo "git" | passwd --stdin git

			echo "> Switching to the git user..."
			sudo su git

			echo "> Making the .ssh directory..."
			sudo -S mkdir -p /home/git/.ssh

			echo "> Giving the git user permission to the .ssh directory..."
			sudo -S chmod 700 /home/git/.ssh

			echo "> Setting up authorized keys for git..."
			sudo mv ${HOMEPATH}/authorized_keys /home/git/.ssh/authorized_keys

			echo "> Granting access to authorized keys..."
			sudo -S chmod 600 /home/git/.ssh/authorized_keys
			sudo chown -R git:git /home/git/.ssh

			echo
			echo "Create the remote .git project..."
			echo "> Cleaning up previous configuration..."
			sudo rm -rf /srv/git/${PROJECT}

			echo "> Making a .git project..."
			sudo mkdir -p /srv/git/${PROJECT}

			echo "> Initialize the .git project..."
			cd /srv/git/${PROJECT}
			sudo -S git init --bare
			sudo chown -R git:git ../${PROJECT}

			echo
			echo "git remote add origin git@${HOST}:/srv/${PROJECT}"
			echo

			echo
			echo "Changing the shell..."
			env zsh -l
			echo "Bye for now!"
			exit			
EOF
		print "Install oh my zsh theme"
		scp -P 22 robbyrussell.zsh-theme ${USERNAME}@${HOST}:${HOMEPATH}/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme
		status

		print "Use customized .zshrc file"
		scp -P 22 zshrc ${USERNAME}@${HOST}:${HOMEPATH}/.zshrc
		status
		print "Done!"

	fi
fi



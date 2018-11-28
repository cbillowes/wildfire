#!/bin/bash
echo "Configure new .git project on remote host."
echo "example: use this configuration for private local backup versioned storage."
echo ""

function help {
	echo "usage: ./remote-setup.sh "
	echo " -h | --help"    : shows this menu
	echo " -u | --username : used to authenticate to the host through ssh"
	echo " -o | --host     : the host address the ssh connection must be made to"
	echo " -k | --key      : location of public key to be added to authorized keys"
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
		    shift # past argument
		    shift # past value
		    ;;
		    -u|--username)
		    USERNAME="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -o|--host)
		    HOST="$2"
		    shift # past argument
		    shift # past value
		    ;;
         	    -k|--key)
	            KEY="$2"
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
		echo "Upgrade system"
		sudo dnf install yum-plugin-fastmirror
		sudo dnf clean
		sudo dnf update -y
		sudo dnf upgrade -y

		echo "Install packages"
		sudo dnf install -y gcc c++ make git vim zash

		echo "Create authorized keys"
		cat $KEY >> authorized_keys
		rsync -r authorized_keys ${USERNAME}@${HOST}:/.ssh

		echo "SSH to ${HOST}"
		ssh ${USERNAME}@${HOST}
		sudo adduser git
		su git
		chmod 700 /.ssh
		touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys

		echo "Create .git project"
		mkdir /srv/git/project.git
		cd /srv/git/project.git
		git init --bare

		echo "Bye now"
		exit

		echo "DONE!"
	fi
fi

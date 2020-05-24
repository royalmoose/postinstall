#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   	echo "This script must be run as root" 
   	exit 1
else
	#Update and Upgrade
	echo "Updating and Upgrading"
	apt-get update && sudo apt-get upgrade -y

	#Fix sources file
	echo "Updating sources.list"
	sudo sed -i 's/ main.*/ main contrib non-free/g' /etc/apt/sources.list
	sudo sed -i 's/.*deb cdrom/# deb cdrom/g' /etc/apt/sources.list

	sudo apt-get install dialog
	cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	options=(1 "Signal" off    # any option can be set to default to "on"
	         2 "Atom" off)
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		clear
		for choice in $choices
		do
		    case $choice in
	        	1)
	            		#Signal*
				echo "Signal"
				wget https://updates.signal.org/desktop/apt/keys.asc | apt-key add keys.asc
				echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | tee -a /etc/apt/sources.list.d/signal-xenial.list
				apt update
				apt install signal-desktop -y
				rm -f keys.asc
				;;
	        	2)
	            		#Signal*
				echo "Atom"
				wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
				echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list
				apt update
				apt-get install atom -y
				;;


	    esac
	done
fi
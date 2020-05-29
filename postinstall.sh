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

	sudo apt-get install dialog wget 
	cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
	options=(
			#Drivers
			1 "Debian Preliminaries" off
			2 "ThinkPad L480 drivers" off

			#Desktop Environments
			3 "xfce4" off

			#Communication
			4 "GnuPG" off
			5 "Signal Messenger" off
			6 "WhatsApp" off
			7 "Tutanota" off

			#Development
	         	8 "Atom" off
			9 "Geany" off

			)
		choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
		clear
		for choice in $choices
		do
		    case $choice in
	        	1)
	            		#Debian Preliminaries
				echo "Debian Preliminaries"
				apt install firmware-linux dkms build-essential firmware-iwlwifi -y
				;;

	        	2)
	            		#Thinkpad L480 Drivers
				echo "Fixing trackpad issue"
				echo -n "elantech" > sys/bus/serio/sevices/serio/prorocol
				echo "Applying permanent fix"
				sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="psmouse.elantech_smbus=0"/g' /etc/default/grub
				;;
	        	5)
	            		#Signal Messenger
				echo "Installing Signal Messenger"
				wget https://updates.signal.org/desktop/apt/keys.asc | apt-key add keys.asc
				echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | tee -a /etc/apt/sources.list.d/signal-xenial.list
				apt update
				apt install signal-desktop -y
				rm -f keys.asc
				;;
	        	8)
	            		#Atom
				echo "Atom"
				wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
				echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list
				apt update
				apt-get install atom -y
        #Fix permissions prior to first run
				chown root:root /usr/share/atom/chrome-sandbox
				chmod 4755 /usr/share/atom/chrome-sandbox
        #Git config
        git config --global user.name royalmoose
        git config --global user.email moosie@tutanota.de
        git config --global user.signingkey A72F6D82CCE9EF8F

				;;


	    esac
	done
fi

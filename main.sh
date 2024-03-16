#!/bin/bash
clear
# Function to display the main menu
function display_menu() {

printf "\e[0m\n"
printf "\e[0m\e[92m  _        _      ____        ______   _     __\e[0m\e[93m  _________   ________      ____        ______   ________ \e[0m\n"
printf "\e[0m\e[92m | |	  | |    / __ \      / _____| | |   / /\e[0m\e[93m |_________| |  ____  |    / __ \      / _____| | _______|\e[0m\n"
printf "\e[0m\e[92m | |      | |   / /  \ \    / /       | |  / / \e[0m\e[93m     | |     | |    | |   / /  \ \    / /       | |       \e[0m\n"
printf "\e[0m\e[92m | |______| |  / /____\ \  | |        | | / /  \e[0m\e[93m     | |     | |____| |  / /____\ \  | |        | |______ \e[0m\n"
printf "\e[0m\e[92m | |______| | | |______| | | |        | |/ /   \e[0m\e[93m     | |     | ___  __| | |______| | | |        | _______|\e[0m\n"
printf "\e[0m\e[92m | |      | | | |      | | | |        | | / \  \e[0m\e[93m     | |     | |  \ \   | |      | | | |        | |       \e[0m\n"
printf "\e[0m\e[92m | |      | | | |      | |  \ \_____  | |/ \ \ \e[0m\e[93m     | |     | |   \ \  | |      | |  \ \_____  | |______ \e[0m\n"
printf "\e[0m\e[92m |_|      |_| |_|      |_|   \______| |_|   \_\ \e[0m\e[93m    |_|     |_|    \_\ |_|      |_|   \______| |________|\e[0m\n"
printf "\e[0m\n"
printf " \e[0m\e[1;41m Malware Forensics Tool  [BY : LegaLogic Pioneers ]\e[0m\n"
printf "\e[0m\n"

echo "Welcome to Forensics and Malware Analysis Script!"

 	echo "Select an option :"
	echo "1) Persistence Techniques for Linux"
	echo "2) Memory forensics"
	echo "3) Rootkit Detection"
	echo "4) Steganography"
 	echo "5) Exit"
}
function persistence_techniques () {
	while true; do
	echo "Linux Persistence Techniques"
	echo "1)  Environment Variables"
	echo "2)  Locating Linux Startup scripts"
	echo "3)  Finding existing cron jobs"
	echo "4)  Mounts and Partitions"
	echo "5)  Systemd services"
	echo "6)  Persisting user data"
	echo "7)  Process Monitoring"
	echo "8)  Persistent RAM disk"
	echo "9)  Network File System"
	echo "10) Malicious Databases"
	echo "11) Malicious sysconfig files"
	echo "12) Logging and Log Rotation"
 	echo "13) Back to Main Menu"
	echo "Select a option"
	cd 'Persistence Scripts'
 	read -r choice
  	case $choice in 
	1)
      		bash environmentvariables.sh
		;;
	2)
		bash startupscripts.sh
		;;
	3) 
		bash cronjobs.sh
		;;
	4)
		bash mount.sh
		;;
	5)
		bash system_services.sh
		;;
	6) 
		bash persist.sh
		;;
	7) 
		bash processmonitering.sh
		;;
	8)
		bash ramdisk.sh
		;;
	9)
		bash networkfilesystem.sh
		;;
	10)
		bash mal-database.sh
		;;
	11) 
		bash mal-sysconfig.sh
		;;
	12)
		bash Log-rotations.sh
		;;
        13)
		return
  		;;
  esac
  cd ..
done  		
}

# Function to perform memory forensics using Volatility
function memory_forensics () {
  echo "Enter the path to the memory image: "
  read memory_image

  # Check if Volatility is installed
 # if ! command -v /volatility/volatility &> /dev/null ; then
  #  echo "Error: Volatility is not installed."
   # return 1
  #fi

  # Ask for Volatility commands from the user
  echo "Enter Volatility commands (separate them with spaces):"
  read -r volatility_commands

  # Run Volatility commands on the memory image
  # volatility -f $memory_image $volatility_commands
  cd MemoryForensicsTools/volatility
  python2 vol.py -f $memory_image $volatility_commands
  cd ../..
}

# Function to detect rootkits (replace 'rootkit_hunter' with your actual tool)
function rootkit_detection () {
  # Check if your rootkit detection tool is installed
  if ! command -v rkhunter &> /dev/null ; then
    echo "Error: Rootkit detection tool (rootkit_hunter) is not installed. Replace 'rootkit_hunter' with your tool."
    return 1
  fi
  sudo rkhunter --check
}
function steghide () {
	cd Steganography
 	chmod +x *
 	bash stagocracker.sh
}
while true; do
  display_menu
  read -r choice

  case $choice in
    1)
      
      persistence_techniques
      ;;
    2)
      memory_forensics
      ;;
    3)
      rootkit_detection
      ;;
    4)
      steghide
      ;;
    5)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
done

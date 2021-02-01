#!/bin/bash

clear
echo "                 ╔═══════════════╗"
echo "                 ║ !!!WARNING!!! ║"
echo "╔════════════════╩═══════════════╩══════════════════╗"
echo "║ This script comes without any warranty.           ║"
echo "║ If your computer no longer boots, explodes, or    ║"
echo "║ divides by zero, you are the only one responsible ║"
echo "╟╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╢"
echo "║ This script only works on Debian based distros.   ║"
echo "║ An Ubuntu Live ISO is recommended.                ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
read -p "To continue press [ENTER], or Ctrl-C to exit"

title_bar() {
	clear
	echo "╔═════════════════════════════════════════════════════╗"
	echo "║ AMEliorate Windows 10 2004               2020.10.31 ║"
	echo "╚═════════════════════════════════════════════════════╝"
	echo ""
}

# prompts to install git and 7zip if not already installed
title_bar
	echo "This script requires the installation of a few"
	echo "dependencies. Please enter your password below."
	echo ""
sudo apt update
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' git|grep "install ok installed")
echo "Checking for git: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
	echo "curl not found, prompting to install git..."
	sudo apt-get -y install git
fi
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' p7zip-full|grep "install ok installed")
echo "Checking for 7zip: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
	echo "curl not found, prompting to install 7zip..."
	sudo apt-get -y install p7zip-full
fi

# prompts to install fzf if not already installed
title_bar
echo "The program fzf is required for this script to function"
echo "Please allow for fzf to install following this message"
echo "Enter "y" (yes) for all prompts"
echo ""
read -p "To continue press [ENTER], or Ctrl-C to exit"
echo "\n"
title_bar
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

title_bar
echo "Checking for existing AME Backup"
FILE=./AME_Backup/
if [ -d $FILE ]; then
	now=$(date +"%Y.%m.%d.%H.%M")
	7z a AME_Backup_$now.zip AME_Backup/
	rm -rf AME_Backup/
else
   echo "$FILE' not found, continuing"
fi



# start AME process
title_bar
echo "Starting AME process, searching for files..."
Term=(autologger clipsvc clipup DeliveryOptimization DeviceCensus.exe diagtrack dmclient dosvc EnhancedStorage homegroup hotspot invagent microsoftedge.exe msra sihclient slui startupscan storsvc usoclient usocore windowsmaps windowsupdate wsqmcons wua wus)
touch fzf_list.txt
for i in "${Term[@]}"
do
	echo "Looking for $i"
	$HOME/.fzf/bin/fzf -e -f $i >> fzf_list.txt
done

# check if fzf found anything
title_bar
if [ -s fzf_list.txt ]
then
	echo "Directory file not empty, continuing..."
else
	echo "ERROR! no files found, exiting..."
	exit 1	
fi

# directory processing starts here
rm dirs*
touch dirs.txt

# removes some outliers that are needed
awk '!/FileMaps/' fzf_list.txt > fzf_list_cleaned1.txt
awk '!/WinSxS/' fzf_list_cleaned1.txt > fzf_list_cleaned2.txt
awk '!/MSRAW/' fzf_list_cleaned2.txt > fzf_list_cleaned3.txt
awk '!/msrating/' fzf_list_cleaned3.txt > fzf_list_cleaned.txt

# removes everything after the last slash in the file list
sed 's%/[^/]*$%/%' fzf_list_cleaned.txt >> dirs.txt

# removes a trailing slash, repeats several times to get all the directories
for a in {0..12..2}
do
        if [ $a -eq 0 ]
        then
                cat dirs.txt > dirs$a.txt
        fi
        b=$((a+1))
        c=$((b+1))
        sed 's,/$,,' dirs$a.txt >> dirs$b.txt
        sed 's%/[^/]*$%/%' dirs$b.txt >> dirs$c.txt
        cat dirs$c.txt >> dirs.txt
done

# removes duplicates and sorts by length
awk '!a[$0]++' dirs.txt > dirs_deduped.txt
awk '{ print length($0) " " $0; }' dirs_deduped.txt | sort -n | cut -d ' ' -f 2- > dirs_sorted.txt


# creates removal script
awk -v quote='"' '{print "rm -rf " quote $0 quote}' fzf_list_cleaned.txt > remove.sh
echo 'rm -rf "Program Files/Internet Explorer"' | cat - remove.sh > temp && mv temp remove.sh
#echo 'rm -rf "Program Files/WindowsApps"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Program Files/Windows Defender"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Program Files/Windows Mail"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Program Files (x86)/Internet Explorer"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Program Files (x86)/Windows Defender"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Program Files (x86)/Windows Mail"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/System32/wua*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/System32/wups*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/SystemApps/*CloudExperienceHost*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/SystemApps/*ContentDeliveryManager*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/SystemApps/Microsoft.MicrosoftEdge*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/SystemApps/Microsoft.Windows.Cortana*' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf Windows/diagnostics/system/Apps' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Windows/System32/smartscreen.exe"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Windows/System32/smartscreenps.dll"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Windows/System32/SecurityHealthAgent.dll"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Windows/System32/SecurityHealthService.exe"' | cat - remove.sh > temp && mv temp remove.sh
echo 'rm -rf "Windows/System32/SecurityHealthSystray.exe"' | cat - remove.sh > temp && mv temp remove.sh
echo '#!/bin/bash' | cat - remove.sh > temp && mv temp remove.sh
chmod +x remove.sh



title_bar
echo "Removing files"
./remove.sh
echo "Done."
sync
title_bar
rm fzf_list_cleaned.txt
rm fzf_list_cleaned1.txt
rm fzf_list_cleaned2.txt
rm fzf_list_cleaned3.txt
echo "You may now reboot into Windows"

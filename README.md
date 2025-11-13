# NEW Pico-8 Carts - Bash Downloader
*Download &amp; automatically rename Pico-8 carts from the Lexaloffle BBS threads*
An update to kikookoubis git bash script for quickly grabbing Carts from Lexaloffle BBS.
Original found at:
https://github.com/kikookoubis/pico-8-carts-bash-downloader


# How to use the script (in WINDOWS)
NOTE: The original guide on Kikookoubis page was likely for Unix based systems, follow that if you are using Linux/MacOS

-Download and install Git Bash (https://git-scm.com/install/windows), all the defaults are fine.
-Download and place the .sh file into the directory where you want the carts.
-Open the .sh file in notepad, and copy/paste your folder directory on line 2.
-Ctrl+Right Click inside your folder and select "Open Git Bash here"

-Run the following lines
> chmod +x picodownload.sh
> ./picodownload.sh -p "https://www.lexaloffle.com/bbs/?cat=7&carts_tab=1&page=$i"

This grabs all the carts in the first page of the PICO-8 carts forum. Change ?cat= to select other forums. Can probably do it from favorites too.

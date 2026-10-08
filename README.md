#  A Shell Script for a Simple Antivirus Daemon 
A shell script antivrus project. The daemon watches a specific directory (labtestfolder) and scan for any 
suspicious file that might be malicious,prints them and move them to the quarantine directory. A separate 
restore tool is used to allow user review the malicious files and check if it was a flase positive 
and decide what to do with them, to delete them or restore them or keep them quarantined.

# Overview of the code in the folder with the folder heirarchy
antivirus-lab/

|-antivirus.sh
- scans the directory and checks if there are any malicious files based on some predefined rules
- if there is a malicious file, it moves it to the quarantine directory
- it compares the directory-info.last with the directory-info.new if they are different then it scans

|-restor.sh
- goes through the quarantine directory files
- asks the user to choose what to do

|-Makefile
- has a run target (the antivirus), a restore target (the restore tool), and a prepare pre-build step
   that creates malicious_dir if it does not exist. Both targets run prepare first.

|-README.md 

|-labtest/ 

|-quarantine/ 
  has all the malicious files that has been quarantined
  
|-directory-info.last/ 
  previous snapshot of the directory 
  
|-directory-info.new/ 
  current snapshot of the directory

# Prerequisites
## Prerequisites

**Install make to be able to run the Makefile**

```bash
sudo apt update
sudo apt install make
```

**If `flock` is ever missing, it comes from the `util-linux` package**

```bash
sudo apt install util-linux
```

# Step-by-step instructions for running the antivirus and restore tools 
1. Open the terminal
2. create a monitored folder and add some files on it 
```bash
mkdir labtest
cd labtest
nano first.txt
```
write in the first.txt "hello there is is a lab test"
3. start the anitvirus 
```bash
make
```
this creates a quarantine directory if need and then runs antivirus.sh labtest quarantine 10. 
4. to test this open another terminal and make another file(dangerous.txt) and insert test "this file has a virus"
the first interval should echo "dangerous.txt is malicious and it is Deleted"

5. press ctrl+c then go to quarantine to check if the file is moved there or not and check if it is deleted from labtest
6. run "make restore" and you will the see the malicious file displayed and ask you what you want to do with it.
   this tool stops when quarantine is empty

# Where the flagged-extension and flagged-keywords defined
at the top of the antivirus.sh file 
```bash
flagged_extension=(".exe" ".bat"  ".vbs" ".scr" ".ps1")
flagged_content=("virus" "trojan" "malware" "worm" "ransomware")
```
# Bonus 1: Cron Job
antivirus-cron.sh dir malicious_dir does the same scan and quarantine as antivirusd.sh, but it runs one pass and exits. Cron runs it on a schedule, so there is no loop and no sleep.
**Prerequisites**
- Install the cron service and run it
 ```bash
sudo apt update
sudo apt install cron
sudo systemctl enable --now cron
systemctl status cron
```
the status should say "active (runnning)

the script should be executable 
```bash
  chmod +x antivirus-cron.sh
```
**Step by step configuration
1. get full path of the antivirus-lab "pwd"
2. open the crontab
```bash
   crontab -e
```
choose nano

3. add the job :

go to the very bottom of the file and write this as a single line
```bash
  * * * * * sleep 23; /home/user/antivirus-lab/antivirus-cron.sh /home/user/antivirus-lab/labtestfolder /home/user/antivirus-lab/quarantine >> /home/user/antivirus-lab/antivirus-cron.log 2>&1
```
- " * * * * *" means it runs every minute
- waits 23 seconds first
- /home/.../antivirus-cron.sh the script to run
- /home/.../labtest	the folder to monitor (the dir argument)
- /home/.../quarantine	the quarantine folder (the malicious_dir argument)
- >> .../antivirus-cron.log 2>&1	save everything the script prints into a log file

4. save and close
5. check it was saved
   ```bash
   crontab -l
   ```
This prints your cron list, and your line should appear.

6. Test it add a malicious file
7. go to
    ```bash
   cat antivirus-cron.log
   ```
   you will see that it deleted the malicious file and you can make sure by going to quarantine
**cron expression should be to run this scan every 3rd Friday of the month at 12:31 am**
31 0 * * 5 [ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ] && /home/mariam-yamen/antivirus-lab/antivirus-cron.sh /home/mariam-yamen/antivirus-lab/labtest /home/mariam-yamen/antivirus-lab/quarantine >> /home/mariam-yamen/antivirus-lab/antivirus-cron.log 2>&1
- "31 0 * * 5" means 31 minutes, 0 hour, any day of the month ,any month, 5th day of the week (Friday). I didn't use 31 0 15-21 * 5 because cron works differently, here it will either work between 15-21 or at the 5th day of the week not when both terms matches. so I did the next step
- "[ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ]" first it will capture the day of the monthas a text and check if its greater than or equal to 15    AND less than or equal to 21, if both tests passed it will run the script

# Bonus 2: Whitelist
**where is whitelist stored**
   it is stored as a text file in the antivirus-lab directory
**How a file gets added to the whitelist**
   1. an antivirusd.sh quarantine a malicious file
   2. the user tells the restore.sh to restore the file(false positive)
   3. at the restore.sh it move back the file and adds the file name at the whitelist.txt
   4. the antivirus.sh scans the directory, when it detects the malicious file again it checks the whitelist, it finds the file at the whitelist.txt so it ignores it and doesn't quarantine it
**how the daemon checks it during a scan**
   antivirusd.sh and antivirus-cron.sh check the whitelist first, at the top of the check_malicious function, before any extension or keyword rule:
   ```bash
   fname=$(basename "$1")
   if grep -qx "$fname" whitelist.txt; then
       return 1
   fi
   ```
- basename "$1" gets the file name without its folder.
- grep -x only matches a whole line, so a.exe does not match data.exe.
- If the name is found, the function returns 1 ("not malicious") right away, so the file is skipped. It is not printed, moved or deleted.
- If the name is not found, the normal extension and keyword checks run.

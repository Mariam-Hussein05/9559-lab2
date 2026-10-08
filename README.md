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
6. run "make restore" and you will the see the malicious file displayed and ask you what you want to do with it

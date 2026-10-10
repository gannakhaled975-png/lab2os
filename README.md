Antivirus Lab

A small antivirus written in bash. It watches a folder, moves bad files to a quarantine folder, and has a tool to bring back files that were flagged by mistake.

1. Files in the project

lab2os/
├── antivirusd.sh        the antivirus, runs in a loop
├── restore.sh           review and restore quarantined files
├── antivirus-cron.sh    same scan but runs once (for cron)
├── Makefile             shortcuts: make run, make restore
├── README.md
├── whitelist.txt        made automatically when a file is restored
├── test_dir/            the folder being watched
└── malicious_dir/       the quarantine folder


- antivirusd.sh takes 3 arguments: the folder to watch, the quarantine folder, and the seconds to wait between checks.
- restore.sh takes 2 arguments: the watched folder and the quarantine folder.
- antivirus-cron.sh does one scan and stops, so cron can run it.

2. What you need on Ubuntu

sudo apt update
sudo apt install make cron
chmod +x antivirusd.sh restore.sh antivirus-cron.sh
mkdir -p test_dir


3. How to run it

Run the antivirus:

make run


This runs ./antivirusd.sh test_dir malicious_dir 5 and creates malicious_dir if it does not exist.

Now open another terminal and put some files in test_dir. If a file is bad, it is copied to malicious_dir, deleted from test_dir, and this message is printed:


<file> is malicious and it is DELETED


Stop the antivirus with Ctrl+C before using the restore tool (they must not run at the same time).

Run the restore tool:
make restore


It shows the quarantined files with numbers. Type a number to pick a file (or 0 to quit), then choose:

- 1 = restore the file back to test_dir (it was a false positive)
- 2 = delete the file for good
- 3 = leave it and go back to the list

If the quarantine is empty it prints: No malicious files to review.

 4. Where the flagged lists are

Both lists are written inside the scan function in antivirusd.sh (and again in antivirus-cron.sh):

- Extensions: the grep -E line that checks the file name: .exe .bat .vbs .scr .ps1
- Keywords: the grep -i -E line that checks the file content: virus trojan malware worm ransomware (not case sensitive)

5. Cron job 

Before you start:

- Make sure cron is installed and running:

  sudo apt install cron
  sudo systemctl enable --now cron

- Make the script executable: chmod +x antivirus-cron.sh
- Open antivirus-cron.sh and check that the base= line is the real path of your folder (run pwd inside the folder to see it). Mine is /home/gannah/lab2os
- Make sure test_dir exists.

Steps:

1. Run crontab -e (choose nano if it asks).
2. Add this line at the end:

   * * * * * /home/gannah/lab2os/antivirus-cron.sh
3. Save and exit (Ctrl+O, Enter, Ctrl+X).
4. Check it with crontab -l.
5. To stop it, run crontab -e again and delete the line.

Cron starts the script every minute at second 0. The script waits 23 seconds with sleep 23, so the scan happens at second 23.

Cron expression for the 3rd Friday of every month at 12:31 am:


31 0 15-21 * * [ $(date +\%u) = 5 ] && /home/gannah/lab2os/antivirus-cron.sh


The 3rd Friday is always between day 15 and day 21. If you fill both the day of month and the day of week, cron runs when either one matches, so I check the weekday inside the command with date +%u (5 means Friday). The % is written as \% because cron treats % in a special way.

 6. Whitelist 

- Adding a file: when you choose option 1 (restore) in restore.sh, the file name is added to the end of whitelist.txt.
- Checking it: during a scan, antivirusd.sh looks for the file name in whitelist.txt using grep -x -F. If the name is there, the file is skipped even if it has a flagged extension or keyword.
- It stays after a restart: whitelist.txt is a normal file on the disk, so the antivirus still uses it after you stop it and start it again.

#!/bin/bash
#Rohit Zijoo
#Git Repos Rotation Backup

echo 'Backup has started'

### Get all the data intialized for backups
dayOfMonth=$(date +"%d")    #Get Current Day of month
dayOfWeek=$(date +"%u")     #Get Current Day of week
gitRepo=/Groups/git_repo    #Location of git repos to backup
shhKeys=/Users/git/.ssh     #Location of all SSH Keys
backupLocation=/Users/Shared/Jenkins/Home/workspace/Backup_Git_Repos/GIT    #Path to backup drive

#Credentials and location of network drive
user=tfs-git
password=kuqaZa3w
address=dfs02.tituscorp.local
nameOfShare=GIT

#Check if source git data to be backed up exists
if [ ! -d "$gitRepo" ]; then
    # This means all the git repos are gone. All is lost.
    echo 'Source Git Folder Cannot Be Found'
    exit 1
fi

#Check if ssh keys exist
if [ ! -d "$shhKeys" ]; then
    # This means all the git repos are gone. All is lost.
    echo 'Source Git Folder Cannot Be Found'
    exit 1
fi

#Mount Backup Drive
test -d $backupLocation && echo "$backupLocation Folder exists" || mkdir $backupLocation

mount
if mount | grep -q GIT ; then
    echo 'GIT backup folder already mounted' 
else
    echo '****  GIT backup folder NOT mounted  ****'  
    mount -t smbfs //$user:$password@$address/$nameOfShare $backupLocation
fi

#Example Command For Syncing two folders
#http://www.cyberciti.biz/faq/copy-folder-linux-command-line/
#rsync -av /src /dst

### START OF DAILY BACKUP ### ### START OF DAILY BACKUP ###
echo 'Daily Backup Started'
rsync -av --progress $gitRepo "$backupLocation/git-daily"
rsync -av --progress $shhKeys "$backupLocation/ssh-daily"
echo 'Daily Backup Completed'

### START OF WEEKLY BACKUP ### ### START OF WEEKLY BACKUP ###
if [ "$dayOfWeek" -eq 1 ] ; then   
    echo 'Weekly Backup Started'
    rsync -av --progress $gitRepo "$backupLocation/git-weekly"
    rsync -av --progress $shhKeys "$backupLocation/ssh-weekly"
    echo 'Weekly Backup Started'
else
    echo 'Weekly Backup Not Needed'
fi

### START OF MONTHLY BACKUP ### ### START OF MONTHLY BACKUP ###
if [ "$dayOfMonth" -eq 1 ] ; then
    echo 'Monthly Backup Started' 
    rsync -av --progress $gitRepo "$backupLocation/git-monthly"
    rsync -av --progress $shhKeys "$backupLocation/ssh-monthly"
    echo 'Monthly Backup Started'
else
    echo 'Monthly Backup Not Needed'
fi
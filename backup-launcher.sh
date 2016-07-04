#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 backupDir"
    exit 1
fi

backupDir=$1

# absolute directory check for backupDir
case "$backupDir" in
    /*)
        if [ ! -d "$backupDir" ]
        then
            echo "$backupDir is not a directory"
            exit 1
        fi
        ;;
    *)
        echo "$backupDir is not an absolute path"
        exit 1
        ;;
esac

cd $backupDir

logFile="log-`date '+%a-%Hh'`.log"
touch "$logFile"
chmod og-r "$logFile"
if [ ! -w "$logFile" ]
then
    echo "$logFile is not writable"
    exit 1
fi

if [ ! -f "config.sh" ]
then
    echo "config.sh not found in $backupDir" > "$logFile"
    echo "config.sh not found in $backupDir"
    exit 1
fi

. ./config.sh
success=$?

if [ $success -ne 0 ]
then
    echo "Could not load config.sh" > "$logFile"
    echo "Could not load config.sh"
    exit $success
fi

echo "Starting backup. Use 'tail -f $backupDir/$logFile' to monitor."

`. ./backup.sh 1338 > "$logFile" 2>&1`
success=$?

cat "$logFile"

echo ""
echo "Exit code: $success"
echo ""

if [ $success -ne 0 ]
then
    echo "Backuping PostgreSQL failed"
    if [ $sendgridEnabled -ne 0 ]
    then
        echo "Sending email..."
        ./sendgrid.py "`uname -n`: PostgreSQL backup failed" "$logFile" "$sendgridLogin" "$sendgridPassword" "$sendgridFrom" "$sendgridTo"
        echo "Done"
    fi
    exit $success
fi

if [ $sendgridEnabled -ne 0 -a $weeklyMailEnabled -ne 0 -a "$weeklyMailDay" = `date +%a` -a "$weeklyMailHour" = `date +%H` ]
then
    echo "Sending weekly report email..."
    ./sendgrid.py "`uname -n`: PostgreSQL backup weekly report" "$logFile" "$sendgridLogin" "$sendgridPassword" "$sendgridFrom" "$sendgridTo"
    echo "Done"
fi

echo "All OK, bye."

#!/usr/bin/env bash

if [ $# -ne 1 -o "$1" != '1338' ]
then
    echo "Do not use this script directly. Call backup-launcher.sh instead."
    exit 1
fi

echo -n "Date is "
date

echo ""
echo -n "Machine: "
uname -a
uptime

echo ""
echo -n "Backup directory: "
pwd

echo ""
echo "Contents of directory:"
du -sh *

echo ""
echo "Disk space usage:"
df -h

echo ""
echo "---------------------"
echo ""

mkdir -v dump

for db in "${database[@]}"
do

    dumpFile="$db-`date '+%a-%Hh'`.pgsql"

    echo "Dumping database $db to dump/${dumpFile}..."
    pg_dump --file=dump/$dumpFile --format=custom $db
    success=$?

    if [ $success -ne 0 ]
    then
        echo ""
        echo "pg_dump failed for database $db, removing dump:"
        echo ""
        rm -fvr dump
        exit $success
    fi

done

echo ""
echo "pg_dump OK, tar:"
echo ""

tarFile="${backupName}-`date '+%a-%Hh'`.tar.gz"

tar -cvzf "$tarFile" dump
success=$?

if [ $success -ne 0 ]
then
    echo ""
    echo "tar failed, removing dump and tar:"
    echo ""
    rm -fvr dump
    rm -fvr "$tarFile"
    exit $success
fi

echo ""
echo "tar OK, removing dump:"
echo ""

rm -fvr dump

echo ""
echo "mode change:"
echo ""

chmod -v og-r "$tarFile"

if [ $ftpEnabled -ne 0 ]
then
    echo ""
    echo "Copying via FTP:"
    echo ""
    ncftpput -u "$ftpLogin" -p "$ftpPassword" "$ftpHost" "$ftpFolder" "$tarFile"
    success=$?
    if [ $success -ne 0 ]
    then
        echo ""
        echo "Copy via FTP failed"
        echo ""
        exit $success
    fi
fi

if [ $scpEnabled -ne 0 ]
then
    echo ""
    echo "Copying via SCP:"
    echo ""
    if [ ! -r "$scpSshEnv" ]
    then
        echo "$scpSshEnv does not exist or is not readable"
        exit 1
    fi
    . $scpSshEnv
    scp -v "$tarFile" "$scpPath"
    success=$?
    if [ $success -ne 0 ]
    then
        echo ""
        echo "Copy via SCP failed"
        echo ""
        exit $success
    fi
fi

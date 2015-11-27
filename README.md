pgsql-backup ![project-status](http://stillmaintained.com/paps/pgsql-backup.png)
================================================================================

Shell script for putting `pg_dump` into your crontab.

Useful for small backup scenarios where you only have one PostgreSQL server.

Installation
------------

    git clone https://github.com/paps/pgsql-backup.git
    cd pgsql-backup
    cp config.sh.sample config.sh
    chmod og-rwx config.sh
    vim config.sh

Do not forget to remove read rights on `config.sh` because this file contains passwords.

Usage
-----

`./backup-launcher.sh /absolute/path/to/git/repo`

Crontab
-------

Example for 2 backups per day:

    # m h  dom mon dow   command
     10 13 *   *   *     /home/user/pgsql-backup/backup-launcher.sh /home/user/pgsql-backup > /dev/null 2>&1
     10 21 *   *   *     /home/user/pgsql-backup/backup-launcher.sh /home/user/pgsql-backup > /dev/null 2>&1

The owner of this contrab must have read access to the databases that will be backuped.

Links
-----

PostgreSQL backup & restore documentation: http://www.postgresql.org/docs/current/static/backup.html

`pg_dump` documentation: http://www.postgresql.org/docs/current/static/app-pgdump.html

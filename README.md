# Duplicity backup scripts
Backup/Restore scripts for duplicity with Google drive as backend

## Setup
* scripts have to be in /root/.duplicity/scripts
* config.skel needs to be copied to /root/.duplicity/config and empty vars have to have been configured:
  * ENCRYPT_KEY  : GPG key id
  * REMOTE_DIR   : Remote dir, for Google drive: gdocs://YOUR_GMAIL/SOME_DIR/$HOSTNAME
  * BACKDIRS     : Dirs to backup, without leading /, e.g.: "home var/lib some/other/dir"
  * EMAIL        : Email to send cron mails to
* include/exclude files have to be in /root/.duplicity, and named like this:
  * exclude-common: common patterns that should be ignored for all backups
  * exclude-DIR: where DIR is the directory being backed up, where / is replaced with -, e.g. var/log => var-log

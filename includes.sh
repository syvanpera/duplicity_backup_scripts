#!/bin/bash

function set_lock() {
  (set -C; : > ${1} ) 2> /dev/null
  if [ ${?} != "0" ]; then
    echo "Lock File exists - exiting"
    exit 1
  fi
}

function cleanup() {
  if [[ -f "${LOCK_FILE}" ]]; then
    rm "${LOCK_FILE}"
  fi
  if [[ -f "${ERROR_LOG}" ]]; then
    rm "${ERROR_LOG}"
  fi
  if [ "${ERROR}" -gt 0 ]; then
    if [[ ${NOTIFY_FAILURE_EMAIL:-1} -eq 1 ]]; then
      echo -e "${TYPE} failed:\n${ERROR_MSG}\n\n\n${MSG}" | mailx -s "[CRON]: ${TYPE} of ${HOSTNAME} failed!" "${EMAIL}"
    fi
    if [[ ${NOTIFY_FAILURE_POPUP:-1} -eq 1 ]]; then
      notify_users_error
    fi
  else
    if [[ ${NOTIFY_COMPLETE_EMAIL:-1} -eq 1 ]]; then
      echo -e "${TYPE} completed:${MSG}" | mailx -s "[CRON]: ${TYPE} of ${HOSTNAME} completed" "${EMAIL}"
    fi
    if [[ ${NOTIFY_COMPLETE_POPUP:-1} -eq 1 ]]; then
      notify_users_done
    fi
  fi
  unset PASSPHRASE
  unset GOOGLE_DRIVE_SETTINGS
  unset ENCRYPT_KEY
  unset COMMON_OPTS
  unset BACKUP_OPTS
  unset EXCLUDE_OPTS
  unset DIR_EXCLUDE
  unset REMOTE_DIR
  unset BACKDIRS
  unset EMAIL
  unset TYPE
}

function err_report() {
  local LASTLINE
  local LASTERR
  LASTLINE="${1}"
  LASTERR="${2}"
  ERROR_MSG=$(<"${ERROR_LOG}")
  ERROR_MSG="${ERROR_MSG}\nLine ${LASTLINE}: exit status of last command: ${LASTERR}"
  ERROR=1

  exit "${LASTERR}"
}

# Setup handlers for errors and exit
# NOTE: error handling in bash is... interesting :)
function setup() {
  set_lock "${LOCK_FILE}"
  trap cleanup EXIT
  trap 'err_report ${LINENO} ${?}' ERR

  if [[ ! -d /root/.duplicity/logs ]]; then
    mkdir /root/.duplicity/logs
  fi

  notify_users_start
}

function notify_users_start() {
  if [ -e /usr/bin/notify-send ]; then
    /root/.duplicity/scripts/user-notification.sh "emblem-generic" "Duplicity backup" "... Backup is starting"
  fi
}

function notify_users_done() {
  if [ -e /usr/bin/notify-send ]; then
    /root/.duplicity/scripts/user-notification.sh "emblem-generic" "Duplicity backup" "... Backup completed"
  fi
}

function notify_users_error() {
  if [ -e /usr/bin/notify-send ]; then
    /root/.duplicity/scripts/user-notification.sh "emblem-urgent" "Duplicity backup" "... Backup failed!"
  fi
}

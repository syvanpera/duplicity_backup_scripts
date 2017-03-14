#!/bin/bash
set -o nounset
set -o errexit
set -o errtrace
set -o pipefail
# To debug, enable xtrace, and disable redirection of stderr to file (the exec 2>${ERROR_LOG} line)
#set -o xtrace

if [[ ${EUID} -ne 0 ]]; then
  echo "Needs root access"
  exit 1
fi

MSG=""
ERROR=0
ERROR_MSG=""
ERROR_LOG="/root/.duplicity/logs/duplicity-errors.${$}.log"
TYPE="Backup"

# Redirect all stderr to error logfile
exec 2>${ERROR_LOG}

# For PyDrive credentials
cd /root/.duplicity/
source /root/.duplicity/config
source /root/.duplicity/scripts/includes.sh

setup

for SRC_DIR in ${BACKDIRS}; do
  CLEAN_SRC_DIR=${SRC_DIR//\//-}
  DEST_DIR=${REMOTE_DIR}/${CLEAN_SRC_DIR}
  LOG_FILE="/root/.duplicity/logs/duplicity-${CLEAN_SRC_DIR}.log"

  echo  "========================= Starting backup of ${HOSTNAME}/${SRC_DIR} $(date) =========================" >> "${LOG_FILE}"
  # Pr dir exclude list
  DIR_EXCLUDE=""
  if [[ -f "/root/.duplicity/exclude-${CLEAN_SRC_DIR}-${HOSTNAME}" ]]; then
    DIR_EXCLUDE="--exclude-filelist=/root/.duplicity/exclude-${CLEAN_SRC_DIR}-${HOSTNAME}"
    export DIR_EXCLUDE
  fi
  duplicity incr ${EXCLUDE_OPTS} ${DIR_EXCLUDE} ${COMMON_OPTS} ${BACKUP_OPTS} /${SRC_DIR} ${DEST_DIR} >> "${LOG_FILE}"
  MSG="${MSG}\n- ${SRC_DIR} => ${DEST_DIR}"
done

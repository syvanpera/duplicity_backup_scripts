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
  ORIGINAL_SRC_DIR=${SRC_DIR}
  CLEAN_SRC_DIR=${SRC_DIR//\//-}
  if [[ "${SRC_DIR}" = "/" ]]; then
    CLEAN_SRC_DIR="root"
    SRC_DIR=""
  fi
  DEST_DIR=${REMOTE_DIR}/${CLEAN_SRC_DIR}
  LOG_FILE="/root/.duplicity/logs/duplicity-${CLEAN_SRC_DIR}.log"

  echo  "========================= Starting backup of ${HOSTNAME}/${SRC_DIR} $(date) =========================" >> "${LOG_FILE}"
  # Pr dir exclude list
  DIR_EXCLUDE=""
  if [[ -f "/root/.duplicity/exclude-${CLEAN_SRC_DIR}" ]]; then
    DIR_EXCLUDE="--exclude-filelist=/root/.duplicity/exclude-${CLEAN_SRC_DIR}"
    export DIR_EXCLUDE
  fi
  ENCRYPT_OPT="--no-encryption"
  if [[ "${ENCRYPTDIRS}" =~ $ORIGINAL_SRC_DIR ]]; then
    ENCRYPT_OPT=""
  fi
  duplicity incr ${EXCLUDE_OPTS} ${DIR_EXCLUDE} ${ENCRYPT_OPT} ${COMMON_OPTS} ${BACKUP_OPTS} /${SRC_DIR} ${DEST_DIR} >> "${LOG_FILE}"
  MSG="${MSG}\n- ${SRC_DIR} => ${DEST_DIR}"
done

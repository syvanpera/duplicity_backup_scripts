#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Needs root access"
  exit 1
fi

# For PyDrive credentials
cd /root/.duplicity/
# shellcheck disable=SC1091
source /root/.duplicity/config

if [[ "${#}" -ne 3 ]]; then
  echo "3 arguments are needed:"
  echo "1: File to restore: relative to dir, e.g. hosts"
  echo "2: Remote dir, e.g. etc"
  echo "3: Restore destination, NOTE: should be full path, else it will end up in /root/.duplicity/"
  exit 1
fi

FILE=${1:-}
DIR=${2:-}
CLEAN_DIR=${DIR//\//-}
RESTORE_DEST=${3:-}

echo duplicity ${COMMON_OPTS} --file-to-restore "${FILE}" "${REMOTE_DIR}/${CLEAN_DIR}" "${RESTORE_DEST}"
duplicity ${COMMON_OPTS} --file-to-restore "${FILE}" "${REMOTE_DIR}/${CLEAN_DIR}" "${RESTORE_DEST}"

unset PASSPHRASE
unset ENCRYPT_KEY
unset COMMON_OPTS
unset BACKUP_OPTS
unset EXCLUDE_OPTS
unset DIR_EXCLUDE
unset GOOGLE_DRIVE_SETTINGS
unset REMOTE_DIR
unset BACKDIRS
unset EMAIL

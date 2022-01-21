#!/bin/bash

#########################################################################
# Print Environment
#########################################################################
echo "entrypoint.sh"
echo "  BACKUP_INTERVAL: ${BACKUP_INTERVAL}"
echo "  RSYNC_SOURCE: ${RSYNC_SOURCE}"
echo "  RSYNC_DEST: ${RSYNC_DEST}"
echo "  SQLITE_DATABASE_SOURCE: ${SQLITE_DATABASE_SOURCE}"
echo "  SQLITE_DATABASE_DEST: ${SQLITE_DATABASE_DEST}"
echo "  MIN_BACKUP_SOURCE: ${MIN_BACKUP_SOURCE}"
echo "  MIN_BACKUP_DEST: ${MIN_BACKUP_DEST}"
echo "  MIN_BACKUP_IGNORE_OPTIONS: ${MIN_BACKUP_IGNORE_OPTIONS}"
echo ""

sqlite_backup() {
  #########################################################################
  # SQLite Database Backup
  #########################################################################
  if [ ! -z "${SQLITE_DATABASE_SOURCE}" ] && [ ! -z "${SQLITE_DATABASE_DEST}" ]; then
    echo ""
    echo "Detected SQLite Database backup request"
    if [ -f "${SQLITE_DATABASE_SOURCE}" ]; then
      if [ -f "${SQLITE_DATABASE_DEST}" ]; then
        echo "  Removing previous backup dest file"
        rm ${SQLITE_DATABASE_DEST}
      fi
      if [ "`readlink -f ${SQLITE_DATABASE_SOURCE}`" != "`readlink -f ${SQLITE_DATABASE_DEST}`" ]; then
        echo "echo .dump | sqlite3 ${SQLITE_DATABASE_SOURCE} | sqlite3 ${SQLITE_DATABASE_DEST}"
        echo .dump | sqlite3 ${SQLITE_DATABASE_SOURCE} | sqlite3 ${SQLITE_DATABASE_DEST}
        if [ "$?" == "0" ]; then
          echo "Fixing Permissions for backup file"
          chmod $( stat -c '%a' "${SQLITE_DATABASE_SOURCE}" ) "${SQLITE_DATABASE_DEST}"
          chown $( stat -c '%u' "${SQLITE_DATABASE_SOURCE}" ) "${SQLITE_DATABASE_DEST}"
          chgrp $( stat -c '%g' "${SQLITE_DATABASE_SOURCE}" ) "${SQLITE_DATABASE_DEST}"
          echo "Successfully backed up file: ${SQLITE_DATABASE_SOURCE} -> ${SQLITE_DATABASE_DEST}"
        else
          echo "ERROR: SQLite backup failed"
          return 1
        fi
      else
        echo "ERROR: The SQLite source and dest file are the same"
        return 1
      fi
    else
      echo "ERROR: The SQLITE_DATABASE_SOURCE file does not exist: ${SQLITE_DATABASE_SOURCE}"
      return 1
    fi
    echo ""
  fi
  return 0
}


rsync_backup() {
  #########################################################################
  # Rsync Backup
  #########################################################################

  if [ ! -z "${RSYNC_SOURCE}" ] && [ ! -z "${RSYNC_DEST}" ]; then
    echo ""
    echo "Detected Rsync backup request"
    if [ -f "${RSYNC_SOURCE}" ] || [ -d "${RSYNC_SOURCE}" ]; then
      if [ "`readlink -f ${RSYNC_SOURCE}`" != "`readlink -f ${RSYNC_DEST}`" ]; then
        echo "rsync -avzh ${RSYNC_SOURCE} ${RSYNC_DEST}"
        rsync -avzh ${RSYNC_SOURCE} ${RSYNC_DEST}
        if [ "$?" == 0 ]; then
          echo "Successfully backed source: ${RSYNC_SOURCE} -> ${RSYNC_DEST}"
        else
          echo "ERROR: Rsync command failed"
          return 1
        fi
      else
        echo "ERROR: The rsync source and dest is the same"
        return 1
      fi
    else
      echo "ERROR: The RSYNC_SOURCE does not exist: ${RSYNC_SOURCE}"
      return 1
    fi
    echo ""
  fi
  return 0
}

min_backup() {
  #########################################################################
  # Minimal Backup Backup
  #########################################################################
  if [ ! -z "${MIN_BACKUP_SOURCE}" ] && [ ! -z "${MIN_BACKUP_DEST}" ]; then
    echo ""
    echo "Detected Rsync backup request"
    if [ -f "${MIN_BACKUP_SOURCE}" ] || [ -d "${MIN_BACKUP_SOURCE}" ]; then
      if [ "`readlink -f ${MIN_BACKUP_SOURCE}`" != "`readlink -f ${MIN_BACKUP_DEST}`" ]; then

        declare -a excludes

        OPTIONS=($MIN_BACKUP_IGNORE_OPTIONS)

        for i in "${OPTIONS[@]}"
        do
          excludes+=( --exclude="$i" )
        done

        echo "rsync -avh ${excludes[@]} ${MIN_BACKUP_SOURCE} ${MIN_BACKUP_DEST}"
        rsync -avh "${excludes[@]}" --delete --delete-excluded ${MIN_BACKUP_SOURCE} ${MIN_BACKUP_DEST}
        if [ "$?" == 0 ]; then
          echo "Successfully backed source: ${MIN_BACKUP_SOURCE} -> ${MIN_BACKUP_DEST}"
        else
          echo "ERROR: Rsync command failed"
          return 1
        fi
      else
        echo "ERROR: The rsync source and dest is the same"
        return 1
      fi
    else
      echo "ERROR: The MIN_BACKUP_SOURCE does not exist: ${MIN_BACKUP_SOURCE}"
      return 1
    fi
    echo ""
  fi
  return 0
}


main() {
  if [ -n "${BACKUP_INTERVAL}" ]; then
    if (( ${BACKUP_INTERVAL} > 0 )); then
      echo "Backuping up with interval: ${BACKUP_INTERVAL}"
      while true; do
        sqlite_backup
        sqlite_backup_retval=$?
        rsync_backup
        rsync_backup_retval=$?
        min_backup
        min_backup_retval=$?
        if [ "$(( sqlite_backup_retval | rsync_backup_retval | min_backup_retval ))" == "1" ]; then
          echo "WARNING: A sync failed"
        fi
        sleep ${BACKUP_INTERVAL}
      done
    else
      echo "ERROR: The BACKUP_INTERVAL is 0 or an invalid number"
      return 1
    fi
  else
    sqlite_backup
    sqlite_backup_retval=$?
    rsync_backup
    rsync_backup_retval=$?
    min_backup
    min_backup_retval=$?
    return $(( sqlite_backup_retval | rsync_backup_retval | min_backup_retval ))
  fi
}

main
exit $?

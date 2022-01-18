#!/bin/bash

#########################################################################
# Print Environment
#########################################################################
echo "entrypoint.sh"
echo "  RSYNC_SOURCE: ${RSYNC_SOURCE}"
echo "  RSYNC_DEST: ${RSYNC_DEST}"
echo "  SQLITE_DATABASE_SOURCE: ${SQLITE_DATABASE_SOURCE}"
echo "  SQLITE_DATABASE_DEST: ${SQLITE_DATABASE_DEST}"
echo ""

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
      echo .dump | sqlite3 ${SQLITE_DATABASE_SOURCE} | sqlite3 ${SQLITE_DATABASE_DEST}
      if [ "$?" == "0" ]; then
        echo "Successfully backed up file: ${SQLITE_DATABASE_SOURCE} -> ${SQLITE_DATABASE_DEST}"
        chown --reference=${SQLITE_DATABASE_SOURCE} ${SQLITE_DATABASE_DEST}
        chgrp --reference=${SQLITE_DATABASE_SOURCE} ${SQLITE_DATABASE_DEST}
        chmod --reference=${SQLITE_DATABASE_SOURCE} ${SQLITE_DATABASE_DEST}
      else
        echo "ERROR: SQLite backup failed"
        exit 1
      fi
    else
      echo "ERROR: The SQLite source and dest file are the same"
      exit 1
    fi
  else
    echo "ERROR: The SQLITE_DATABASE_SOURCE file does not exist: ${SQLITE_DATABASE_SOURCE}"
    exit 1
  fi
  echo ""
fi

#########################################################################
# Rsync Backup
#########################################################################

if [ ! -z "${RSYNC_SOURCE}" ] && [ ! -z "${RSYNC_DEST}" ]; then
  echo ""
  echo "Detected Rsync backup request"
  if [ -f "${RSYNC_SOURCE}" ] || [ -d "${RSYNC_SOURCE}" ]; then
    if [ "`readlink -f ${RSYNC_SOURCE}`" != "`readlink -f ${RSYNC_DEST}`" ]; then
      rsync -avzh ${RSYNC_SOURCE} ${RSYNC_DEST}
      if [ "$?" == 0 ]; then
        echo "Successfully backed source: ${RSYNC_SOURCE} -> ${RSYNC_DEST}"
      else
        echo "ERROR: Rsync command failed"
        exit 1
      fi
    else
      echo "ERROR: The rsync source and dest is the same"
      exit 1
    fi
  else
    echo "ERROR: The RSYNC_SOURCE does not exist: ${RSYNC_SOURCE}"
    exit 1
  fi
  echo ""
fi

exit 0
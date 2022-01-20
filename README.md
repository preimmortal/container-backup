# Simple backup tool container based on alpine

A simple backup Docker image to used to backup volumes using rsync and databases using sqlite3

# Manual Usage

Backup files manually. Mount directories using `docker volume`

## Rsync

    docker run --rm -v sourceTarget:/dataSource/ -v destTarget:/dataDest/ preimmortal/container-backup \
             rsync -avzx --numeric-ids /dataSource/ /dataDest/

## Sqlite

    docker run --rm -v /path/to/source:/dataSource -v /path/to/dest:/dataDest preimmortal/container-backup \
              sh -c 'echo ".dump" | sqlite3 /dataSource/db.sqlite3 | sqlite3 /dataDest/db.sqlite3'

# Automated Usage using Environment Variables

- `SQLITE_DATABASE_SOURCE` SQLite Database Source
- `SQLITE_DATABASE_DEST` SQLite Database Dest
- `RSYNC_SOURCE` Rsync Source directory or file
- `RSYNC_DEST` Rsync Destination

## Rsync Environment Example

    docker run --rm \
      -v /path/to/source:/dataSource \
      -v /path/to/dest:/dataDest \
      -e RSYNC_SOURCE=/dataSource/ \
      -e RSYNC_DEST=/dataDest \
      preimmortal/container-backup

## SQLite Environment Example

    docker run --rm \
      -v /path/to/source:/dataSource \
      -v /path/to/dest:/dataDest \
      -e SQLITE_DATABASE_SOURCE=/dataSource/test.db \
      -e SQLITE_DATABASE_DEST=/dataDest/test.db \
      preimmortal/container-backup

## Backup Rsync Environment Example

    docker run --rm \
      -v /path/to/source:/dataSource \
      -v /path/to/dest:/dataDest \
      -e MIN_BACKUP_SOURCE=/dataSource/ \
      -e MIN_BACKUP_DEST=/dataDest \
      -e MIN_BACKUP_IGNORE_OPTIONS="*file1* *file2*" \
      preimmortal/container-backup

# Full Example

    docker run --rm \
      -v /path/to/source:/dataSource \
      -v /path/to/dest:/dataDest \
      -e RSYNC_SOURCE=/dataSource/ \
      -e RSYNC_DEST=/dataDest \
      -e SQLITE_DATABASE_SOURCE=/dataSource/test.db \
      -e SQLITE_DATABASE_DEST=/dataDest/test.db \
      preimmortal/container-backup

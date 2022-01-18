# Simple backup tool container based on alpine

A simple backup Docker image to used to backup volumes using rsync and databases using sqlite3

## Rsync Usage

Get files from remote server within a `docker volume`:

    docker run --rm -v sourceTarget:/dataSource/ -v destTarget:/dataDest/ preimmortal/container-backup \
             rsync -avzx --numeric-ids /dataSource/ /dataDest/

## Sqlite Usage

    docker run --rm -v sourceTarget:/dataSource/ -v destTarget:/dataDest/ preimmortal/container-backup \
             echo ".dump" | /dataSource/sqlite3 test.db| sqlite3 /dataDest/test.db

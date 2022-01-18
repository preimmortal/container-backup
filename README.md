# Simple backup tool container based on alpine

A simple backup Docker image to used to backup volumes using rsync and databases using sqlite3

## Rsync Usage

Get files from remote server within a `docker volume`:

    docker run --rm -v sourceTarget:/dataSource/ -v destTarget:/dataDest/ preimmortal/container-backup \
             rsync -avzx --numeric-ids /dataSource/ /dataDest/

## Sqlite Usage

    docker run --rm -v /path/to/source:/dataSource -v /path/to/dest:/dataDest preimmortal/container-backup \
              sh -c 'echo ".dump" | sqlite3 /dataSource/db.sqlite3 | sqlite3 /dataDest/db.sqlite3'

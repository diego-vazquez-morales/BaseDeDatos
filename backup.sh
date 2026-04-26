#!/bin/bash
# backup_ridehailing.sh
FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="."
RETENTION_DAYS=5


# creamos backup comprimido para que no ocupe tanto
docker exec mysql mysqldump \
  -uroot -prootpass \
  --databases rideHailing \
  --single-transaction \
  --routines --triggers --events \
  --set-gtid-purged=OFF \
  > "${BACKUP_DIR}/backup_${FECHA}.sql"

  # comprobar si se creo correctamente
if [ $? -eq 0 ]; then
    echo "Backup creado: backup_${FECHA}.sql"
else
    echo "ERROR: Backup falló" >&2
    exit 1
fi
#eliminamos los backups con mas de 5 dias
find ${BACKUP_DIR} -name "backup_*.sql" -mtime +${RETENTION_DAYS} -delete
echo "Backups con más de ${RETENTION_DAYS} días eliminados"

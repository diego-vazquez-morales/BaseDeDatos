#!/bin/bash
# backup_ridehailing.sh
FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="."
RETENTION_DAYS=5

mkdir -p "${BACKUP_DIR}"
# creamos backup comprimido para que no ocupe tanto
docker exec mysql mysqldump \
  -uroot -prootpass \
  --databases rideHailing \
  --single-transaction \
  --routines --triggers --events \
  -set-gtid-purged=OFF \
  | gzip > "${BACKUP_DIR}/backup_${FECHA}.sql.gz"
  # comprobar si se creo correctamente
if [ $? -eq 0 ]; then
    echo "Backup creado: backup_${FECHA}.sql.gz"
else
    echo "ERROR: Backup falló" >&2
    exit 1
fi
#eliminamos los backups con mas de 5 dias
find ${BACKUP_DIR} -name "backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo "Backups con más de ${RETENTION_DAYS} días eliminados"
# Para que el backup se ejecute cada hora.
# 0 * * * * /scripts/backup_ridehailing.sh >> /var/log/mysql_backup.log 2>&1
#mirar comando backup cron con el comando 0 * * * para el cronograma de esto q se pone en la consola
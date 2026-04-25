

-- Plan de backup.sql

--Si analizamos el contexto estamos base de datos para una plataforma de ride-hailing que es un negocio que opera en tiempo real
-- y en caso de que fallara el sistema perder datos como los pagos, si un conductor acepto una oferta, o el cambio de un estado de un viaje
--de en curso a finalizado puede ser critico tanto para la empresa como para los usuarios.
--Entonces teniendo todo eso encuenta podemos defineir el RPO y el RTO
--Definimos el RPO =  hora --> que es la maxima 1 hora de perdida de datos  y un RTO de = 4 horas donde el sistema pueda restaurarse.
--Pero apuntamos a crear un sistema hibrido con backup completo + binlog + replicas para hacerlo de la forma mas segura.

--Al final del .sql vienen los pasos para ejecutar los backups

--Verificar que el Binlog esta activo  para PITR (recuperar en el momento exacto)
SHOW VARIABLES LIKE 'log_bin';                       -- Debe ser ON
SHOW VARIABLES LIKE 'binlog_format';                 -- Recomendado: ROW
SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';    -- Retención en segundos

-- Ver los archivos de binlog disponibles actualmente
SHOW BINARY LOGS;


--Con la poca cantidad de datos que manejamos vamos a optar por un backup logico 
--antes que por uno fisico ya que asi es mas tiene una mayor portabiliad y es mas senciullo
-
--  AUTOMATIZACION DE LOS BACKUPS
--  Dejamos automatizados los backups para que se realicen cada hora y eliminen los backups que tengan mas de 5 dias

-- #!/bin/bash
-- # backup_ridehailing.sh
--
-- FECHA=$(date +%Y%m%d_%H%M%S)
-- BACKUP_DIR="/backups/mysql"
-- RETENTION_DAYS=5
--
-- # creamos backup comprimido para que no ocupe tanto
-- docker exec mysql mysqldump \
--   -uroot -prootpass \
--   --databases rideHailing \
--   --single-transaction \
--   --routines --triggers --events \
--   --set-gtid-purged=OFF \
--   | gzip > "${BACKUP_DIR}/backup_${FECHA}.sql.gz"
--
-- # comprobar si se creo correctamente
-- if [ $? -eq 0 ]; then
--   echo "Backup creado: backup_${FECHA}.sql.gz"
-- else
--   echo "ERROR: Backup falló" >&2
--   exit 1
-- fi
--
--  #eliminamos los backups con mas de 5 dias
-- find ${BACKUP_DIR} -name "backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
-- echo "Backups con más de ${RETENTION_DAYS} días eliminados"
--
--  # Para que el backup se ejecute cada hora.
--   0 * * * * /scripts/backup_ridehailing.sh >> /var/log/mysql_backup.log 2>&1



-- restauramos el archivo backup sql que necesitamos
--
--   gunzip -c backup_rideHailing_Fecha.sql.gz  \ #poner nombre tu archivo
--     | docker exec -i mysql mysql -uroot -prootpass
--


--  Uso de PITR 
--
--Pitr nos permite recuperar la bd haste el momento exacto graciasn a binlog

-- PASOS (ejecutar en terminal):
--
--   1. Restaurar el ultimo backup
--     gunzip -c backup_rideHailing_Fecha.sql.gz  \ #poner nombre tu archivo
--        | docker exec -i mysql mysql -uroot -prootpass
--
--   2. Extraer del binlog solo los cambios hasta a hora necesaria
--      docker exec mysql mysqlbinlog \
--        --start-datetime="año-mes-dia hora:minuto:segundos" \ #hora de inicio
--        --stop-datetime="año-mes-dia hora:minuto:segundos" \ #hora de fin
--        /var/lib/mysql/binlog.000001 > cambios.sql
--
--   3. Aplicar esos cambios sobre la BD restaurada
--      cat cambios.sql | docker exec -i mysql mysql -uroot -prootpass



--  Comprobamos si se verifico todo correctamnte
USE rideHailing;

-- ver si todas las tablas existen
SHOW TABLES;

-- contamos las filas de cada tabla
SELECT 'company'         AS tabla, COUNT(*) AS filas FROM company
UNION ALL
SELECT 'rider',                    COUNT(*)          FROM rider
UNION ALL
SELECT 'conductor',                COUNT(*)          FROM conductor
UNION ALL
SELECT 'vehiculo',                 COUNT(*)          FROM vehiculo
UNION ALL
SELECT 'viaje',                    COUNT(*)          FROM viaje
UNION ALL
SELECT 'oferta',                   COUNT(*)          FROM oferta
UNION ALL
SELECT 'oferta_conductor',         COUNT(*)          FROM oferta_conductor
UNION ALL
SELECT 'empresa_vehiculo',         COUNT(*)          FROM empresa_vehiculo;

-- vemos que las claves foraneas no aparezcan desligadas
SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'rideHailing'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Mostramos los 7 dias todos los viajes para ver si muestra datos coherentes
SELECT estado, COUNT(*) AS total
FROM viaje
WHERE creado_en >= NOW() - INTERVAL 7 DAY
GROUP BY estado;


-- Verificar que el usuario de backup existe y tiene los permisos correctos (debe tener los permisos minimos)
USE mysql;
SELECT user, host, plugin, account_locked
FROM mysql.user
WHERE user = 'backup';

SHOW GRANTS FOR 'backup'@'localhost';



--Pasos para ejecutar el codigo de backup automatico
--1. docker compose up -d
--2. docker compose ps
--3. ejecutar: La automatizacion del backup
#!/bin/bash
 # backup_ridehailing.sh
 FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/mysql"
RETENTION_DAYS=5

mkdir -p "${BACKUP_DIR}"
 # creamos backup comprimido para que no ocupe tanto
docker exec mysql mysqldump \
  -uroot -prootpass \
  --databases rideHailing \
  --single-transaction \
  --routines --triggers --events \
  --set-gtid-purged=OFF \
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
-- 0 * * * * /scripts/backup_ridehailing.sh >> /var/log/mysql_backup.log 2>&1
--4. Verificar que se creo ls -lh backup_rideHailing_*.sql.gz

--Pasos de restauracion
--1. docker compose ps
--2. Restaura el ultimo backup:
--   gunzip -c backup_rideHailing_Fecha.sql.gz \ #poner nombre tu archivo cque esta en .gz
--        | docker exec -i mysql mysql -uroot -prootpass
--3. Extraer del binlog solo los cambios hasta a hora necesaria
--      docker exec mysql mysqlbinlog \
--        --start-datetime="año-mes-dia hora:minuto:segundos" \ #hora de inicio
--        --stop-datetime="año-mes-dia hora:minuto:segundos" \ #hora de fin
--        /var/lib/mysql/binlog.000001 > cambios.sql
--4. Aplicar esos cambios sobre la BD restaurada
--      cat cambios.sql | docker exec -i mysql mysql -uroot -prootpass
--5. hacer pruebas tras restore


docker exec -it mysql mysql -uroot -prootpass
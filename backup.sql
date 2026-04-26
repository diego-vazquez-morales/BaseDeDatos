

-- Plan de backup.sql

--Si analizamos el contexto estamos base de datos para una plataforma de ride-hailing que es un negocio que opera en tiempo real
-- y en caso de que fallara el sistema perder datos como los pagos, si un conductor acepto una oferta, o el cambio de un estado de un viaje
--de en curso a finalizado puede ser critico tanto para la empresa como para los usuarios.
--Entonces teniendo todo eso encuenta podemos defineir el RPO y el RTO
--Definimos el RPO =  hora --> que es la maxima 1 hora de perdida de datos  y un RTO de = 4 horas donde el sistema pueda restaurarse.
--En caso de que se necesitara una restauracion mas rapida por ser datos muy importantes siempre podemos actualizar los backups para que se 
--hagan de orma automatica cada menos tiempo de 1h.



--Con la poca cantidad de datos que manejamos vamos a optar por un backup logico 
--antes que por uno fisico ya que asi es mas tiene una mayor portabiliad y es mas senciullo
-
--  AUTOMATIZACION DE LOS BACKUPS
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

--
--  Para que el backup se ejecute cada hora (linux)
--   0 * * * * /scripts/backup_ridehailing.sh >> /var/log/mysql_backup.log 2>&1
--  Para que el backup se ejecute cada hora  (windows) desde git bash
--while true; do
--    bash backup.sh
--    sleep 3600
--done

-- restauramos el archivo backup sql que necesitamos
--
-- docker exec -i mysql mysql -uroot -prootpass < backup_FECHA.sql
--



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
--3.1 ejecutar en git bash (para windows ):
--while true
--do
--    bash backup.sh
--    sleep 10
--done
--3.2 ejecutar en terminal (para Linux):
-- 0 * * * * cd "/ruta/BaseDeDatos" && bash backup.sh >> backup.log 2>&1

--4. Verificar que se creo ls -lh backup_rideHailing_*.sql con el horario exacto

--Pasos de restauracion
--1. docker compose ps
--2. Restaura el ultimo backup:
--   docker exec -i mysql mysql -uroot -prootpass < backup_FECHA.sql
--4. hacer pruebas tras restore



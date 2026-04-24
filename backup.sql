

-- Plan de backup.sql

--Si analizamos el contexto estamos base de datos para una plataforma de ride-hailing que es un negocio que opera en tiempo real
-- y en caso de que fallara el sistema perder datos como los pagos, si un conductor acepto una oferta, o el cambio de un estado de un viaje
--de en curso a finalizado puede ser critico tanto para la empresa como para los usuarios.
--Entonces teniendo todo eso encuenta podemos defineir el RPO y el RTO
--Definimos el RPO =  hora --> que es la maxima 1 hora de perdida de datos  y un RTO de = 4 horas donde el sistema pueda restaurarse.
--Pero apuntamos a crear un sistema hibrido con backup completo + binlog + replicas para hacerlo de la forma mas segura.

--Verificar que el Binlog esta activo  para PITR (recuperar en el momento exacto)
SHOW VARIABLES LIKE 'log_bin';                       -- Debe ser ON
SHOW VARIABLES LIKE 'binlog_format';                 -- Recomendado: ROW
SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';    -- Retención en segundos

-- Ver los archivos de binlog disponibles actualmente
SHOW BINARY LOGS;


--Con la poca cantidad de datos que manejamos vamos a optar por un backup logico 
--antes que por uno fisico ya que asi es mas tiene una mayor portabiliad y es mas senciullo
-- ─────────────────────────────────────────────────────────────────

--Preguntar equipo cual prefiere


-- COMANDO ((ejecutar en la terminal)
--
--   docker exec mysql mysqldump \
--     -uroot -prootpass \
--     --databases rideHailing \
--     --single-transaction \
--     --routines --triggers --events \
--     --set-gtid-purged=OFF \
--     > backup_rideHailing_$(date +%Y%m%d).sql
--
-- Para incluir también usuarios y privilegios (base de datos mysql):
--
--   docker exec mysql mysqldump \
--     -uroot -prootpass \
--     --all-databases \
--     --single-transaction \
--     --routines --triggers --events \
--     --set-gtid-purged=OFF \
--     > backup_completo.sql
--



-- la restauracion (ejecutar desde terminal/bash)
--
-- Una vez tenemos el archivo .sql, lo restauramos así:
--
--   cat backup_rideHailing_FECHA.sql \
--     | docker exec -i mysql mysql -uroot -prootpass
--
────────────────────────────────────────────
-- Verificacion tras restauracion
--
--Tras la restauracion hacemos comandos basicos para saber si todo esta bien

USE rideHailing;

-- Verificar que todas las tablas existen
SHOW TABLES;

-- Conteo de filas por tabla para comparar con el backup original
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

-- Verificar integridad de las claves foráneas (no deben aparecer huérfanos)
SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'rideHailing'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Consulta crítica de negocio: viajes en los últimos 7 días
-- Si devuelve resultados coherentes, el restore fue correcto
SELECT estado, COUNT(*) AS total
FROM viaje
WHERE creado_en >= NOW() - INTERVAL 7 DAY
GROUP BY estado;



--  Uso de PITR 
--
--Pitr nos permite recuperar la bd haste el momento exacto graciasn a binlog

-- PASOS (ejecutar en terminal):
--
--   1. Restaurar el ultimo backup
--      cat backup_rideHailing_20250101.sql \
--        | docker exec -i mysql mysql -uroot -prootpass
--
--   2. Extraer del binlog solo los cambios hasta a hora necesaria
--      docker exec mysql mysqlbinlog \
--        --start-datetime="2025-01-01 10:00:00" \
--        --stop-datetime="2025-01-01 10:44:59" \
--        /var/lib/mysql/binlog.000001 > cambios.sql
--
--   3. Aplicar esos cambios sobre la BD restaurada
--      cat cambios.sql | docker exec -i mysql mysql -uroot -prootpass
--
-- Para identificar el momento exacto del DELETE en el binlog:
--      docker exec mysql mysqlbinlog \
--        --start-datetime="2025-01-01 10:40:00" \
--        --stop-datetime="2025-01-01 10:50:00" \
--        /var/lib/mysql/binlog.000001 | grep -A5 -B5 "DELETE"
--


-- ─────────────────────────────────────────────────────────────────
-- 7. AUTOMATIZACIÓN CON SCRIPT DE ROTACIÓN
--
-- El siguiente script de bash hace backup diario y borra backups
-- con más de 7 días para no llenar el disco.
-- Basado en: 06_backup.md §7.1 "Script de backup con rotación"
--
-- #!/bin/bash
-- # backup_ridehailing.sh
--
-- FECHA=$(date +%Y%m%d_%H%M%S)
-- BACKUP_DIR="/backups/mysql"
-- RETENTION_DAYS=5
--
-- # Crear backup comprimido
-- docker exec mysql mysqldump \
--   -uroot -prootpass \
--   --databases rideHailing \
--   --single-transaction \
--   --routines --triggers --events \
--   --set-gtid-purged=OFF \
--   | gzip > "${BACKUP_DIR}/backup_${FECHA}.sql.gz"
--
-- # Verificar que se creó correctamente
-- if [ $? -eq 0 ]; then
--   echo "Backup creado: backup_${FECHA}.sql.gz"
-- else
--   echo "ERROR: Backup falló" >&2
--   exit 1
-- fi
--
-- # Eliminar backups con más de 5días
-- find ${BACKUP_DIR} -name "backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
-- echo "Backups con más de ${RETENTION_DAYS} días eliminados"
--
-- Programar con cron para que se ejecute cada día a las 3:00 AM:
--   0 3 * * * /scripts/backup_ridehailing.sh >> /var/log/mysql_backup.log 2>&1

-- ─────────────────────────────────────────────────────────────────
-- 8. USUARIO DE BACKUP
--
-- El usuario 'backup'@'localhost' ya está creado en permissions.sql
-- con los permisos mínimos necesarios: SELECT, LOCK TABLES, SHOW VIEW.
-- Esto sigue el principio de mínimo privilegio: el proceso de backup
-- solo puede leer datos, no modificarlos.
-- Basado en: 06_backup.md §2.2 opción --single-transaction
-- ─────────────────────────────────────────────────────────────────

-- Verificar que el usuario de backup existe y tiene los permisos correctos
USE mysql;
SELECT user, host, plugin, account_locked
FROM mysql.user
WHERE user = 'backup';

SHOW GRANTS FOR 'backup'@'localhost';



-- Usamos mysql para gestionar los permisos de los usuarios  
USE mysql;

-- Primero eliminamos los usuarios y los roles que podrían existir para evitar errores al crear los nuevos usuarios
DROP USER IF EXISTS 'app'@'%';
DROP USER IF EXISTS 'dashboard'@'%';
DROP USER IF EXISTS 'backup'@'localhost';
DROP USER IF EXISTS 'admin'@'localhost';
DROP ROLE IF EXISTS 'rol_lectura', 'rol_escritura';

/*+-----------------------------------------------------------------------------------------------------+*/
-- Creamos los usuarios:
-- App (INSERT/UPDATE/SELECT datos) => Usuarios que utilizan nuestra apicación
-- Dashboard (solo lectura) => Para herramientas de visualización de datos
-- Backup local => Para el backup
-- ADMIN => admin de la base de datos
-- Todas las contraseñas van a estar hasheadas con SHA-256
/*+-----------------------------------------------------------------------------------------------------+*/

-- Usuario app (puedes acceder desde donde quiera)
CREATE USER 'app'@'%' IDENTIFIED WITH caching_sha2_password BY 'app1234_';

-- Usuario Dashboard (puede acceder desde donde quiera)
CREATE USER 'dashboard'@'%' IDENTIFIED WITH caching_sha2_password BY 'dashboard1234_';

-- Usuario backup local (solo puede acceder localmente)
CREATE USER 'backup'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'backup1234_';

-- Usuario ADMIN local (solo puede acceder localmente)
CREATE USER 'admin'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'dba1234_';

-- PERMISOS DE APP
/*+-----------------------------------------------------------------------------------------------------+*/
-- Permisos para app, selección, inserción y actualización en viaje, oferta y oferta_conductor. 
-- Selección e inserción en rider. Solo selección en conductor, vehiculo y company.
/*+-----------------------------------------------------------------------------------------------------+*/
GRANT SELECT, INSERT, UPDATE ON rideHailing.viaje TO 'app'@'%';
GRANT SELECT, INSERT, UPDATE ON rideHailing.oferta TO 'app'@'%';
GRANT SELECT, INSERT, UPDATE ON rideHailing.oferta_conductor TO 'app'@'%';
GRANT SELECT, INSERT ON rideHailing.rider TO 'app'@'%';
GRANT SELECT ON rideHailing.conductor TO 'app'@'%';
GRANT SELECT ON rideHailing.vehiculo TO 'app'@'%';
GRANT SELECT ON rideHailing.company TO 'app'@'%';

/*+-----------------------------------------------------------------------------------------------------+*/
-- PERMISOS DASBOARD
-- solo lectura en todas las tablas
/*+-----------------------------------------------------------------------------------------------------+*/

GRANT SELECT ON rideHailing.* TO 'dashboard'@'%';
GRANT PROCESS ON *.* TO 'dashboard'@'%';
GRANT SELECT ON performance_schema.* TO 'dashboard'@'%';
GRANT SELECT ON sys.* TO 'dashboard'@'%';

/*+-----------------------------------------------------------------------------------------------------+*/
-- PERMISOS ADMIN
-- Permiso completo para el ADMIN solo en localhost
/*+-----------------------------------------------------------------------------------------------------+*/
GRANT ALL PRIVILEGES ON rideHailing.* TO 'admin'@'localhost';

/*+-----------------------------------------------------------------------------------------------------+*/
-- PERMISOS BACKUP
-- Lectura de todas las tablas, bloqueo de tablas para que no puedan otros modificar tablas mientras
-- se hace la copia de seguridad, y ver las vistas para backup solo en localhost
/*+-----------------------------------------------------------------------------------------------------+*/

GRANT SELECT, LOCK TABLES, SHOW VIEW ON rideHailing.* TO 'backup'@'localhost';

/*+-----------------------------------------------------------------------------------------------------+*/
-- ROLES
-- Rol Lectura  => Permite consultar datos sin poder modificarlos. Asignado a usuarios como dashboard.
-- Rol Escritura => Permite insertar, actualizar y eliminar datos. Asignado a usuarios como app.
/*+-----------------------------------------------------------------------------------------------------+*/
CREATE ROLE 'rol_lectura', 'rol_escritura';

-- rol_lectura puede hacer SELECT en cualquier tabla de ridehailing
GRANT SELECT ON rideHailing.* TO 'rol_lectura';

-- rol_escritura solo puede INSERT y UPDATE en la tabla viaje (no en toda la BD)
GRANT INSERT, UPDATE ON rideHailing.viaje  TO 'rol_escritura';

-- Asignamos los roles a los usuarios correspondientes segun su función
GRANT 'rol_lectura'  TO 'dashboard'@'%';
GRANT 'rol_escritura' TO 'app'@'%';

-- Por defecto MySQL no activa los roles al conectarse, 
-- asi que los activamos automáticamente sin necesidad de hacer SET ROLE manualmente.
SET DEFAULT ROLE ALL TO 'app'@'%';
SET DEFAULT ROLE ALL TO 'dashboard'@'%';

-- Recargamos los privilegios en memoria para que todos los cambios tengan efecto inmediato
FLUSH PRIVILEGES;

/*+-----------------------------------------------------------------------------------------------------+*/
-- VISTAS DE SEGURIDAD
-- Ocultamos las columnas sensibles de rider para que el dashboard no acceda a datos personales directamente
/*+-----------------------------------------------------------------------------------------------------+*/
CREATE OR REPLACE VIEW rideHailing.v_rider_publico AS
SELECT r.id_rider, u.nombre
FROM rideHailing.rider r
JOIN rideHailing.usuario u ON u.id_usuario = r.id_usuario;
 
-- El dashboard accede a la vista pública, no a la tabla completa (sin teléfono, email, etc.)
GRANT SELECT ON rideHailing.v_rider_publico TO 'dashboard'@'%';

/*+-----------------------------------------------------------------------------------------------------+*/
-- GESTIÓN DE CUENTAS
-- Ejemplo en el que bloqueamos backup local cuando no se necesite y expiración de contraseña
/*+-----------------------------------------------------------------------------------------------------+*/
 
-- Bloqueamos la cuenta backup, esto hay que hacerlo cuando no se esté ejecutando el proceso de backup
ALTER USER 'backup'@'localhost' ACCOUNT LOCK;
 
-- Luego la desbloqueamos cuando lo necesitamos
ALTER USER 'backup'@'localhost' ACCOUNT UNLOCK;
 

-- Forzamos el cambio de contraseña en el próximo login
ALTER USER 'app'@'%' PASSWORD EXPIRE;

/*+-----------------------------------------------------------------------------------------------------+*/
-- AUDITORÍA Y SUPERVISIÓN
-- Verificamos que los usuarios existen y comprobamos su estado
/*+-----------------------------------------------------------------------------------------------------+*/
 
-- Ver todas las cuentas y su estado (bloqueadas, contraseña expirada, plugin)
SELECT user, host, plugin, account_locked, password_expired
FROM mysql.user
WHERE user IN ('app', 'dashboard', 'backup', 'admin')
ORDER BY user, host;
 
-- Mostramos los permisos concretos de cada usuario
SHOW GRANTS FOR 'app'@'%';
SHOW GRANTS FOR 'dashboard'@'%';
SHOW GRANTS FOR 'backup'@'localhost';
SHOW GRANTS FOR 'admin'@'localhost';
 
/*+-----------------------------------------------------------------------------------------------------+*/
-- DETECCIÓN DE CONFIGURACIONES INSEGURAS
-- Aquí comprobamos si exsiten cuentas que puedan representar un riesgo para la seguridad de nuestra base de 
-- datos.
/*+-----------------------------------------------------------------------------------------------------+*/
 
-- Mostramos las cuentas que pueden conectarse desde cualquier host 
SELECT user, host FROM mysql.user WHERE host = '%';
 
-- Cuentas que pueden dar permisos a otros usuarios con GRANT OPTION (pueden dar permisos a otros usuarios)
SELECT grantee, privilege_type
FROM information_schema.user_privileges
WHERE privilege_type = 'GRANT OPTION';
 
-- Mostramos las cuentas con permisos globales ON *.* solo deberían tener todos los perimisos root y admin
SELECT grantee, privilege_type
FROM information_schema.user_privileges
WHERE table_catalog = 'def';







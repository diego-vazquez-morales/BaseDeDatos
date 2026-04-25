-- Usamos mysql para gestionar los permisos de los usuarios  
USE mysql;

-- Primero eliminamos los usuarios y los roles que podrían existir para evitar errores al crear los nuevos usuarios
DROP USER IF EXISTS 'app'@'%';
DROP USER IF EXISTS 'dashboard'@'%';
DROP USER IF EXISTS 'backup'@'%';
DROP USER IF EXISTS 'dba'@'localhost';
DROP ROLE IF EXISTS 'rol_lectura', 'rol_escritura';

-- Creamos los usuarios:
-- App (INSERT/UPDATE/SELECT datos) => Usuarios que utilizan nuestra apicación
-- Dashboard (solo lectura) => Para herramientas de visualización de datos
-- Backup local => Para el backup
-- ADMIN => admin de la base de datos
-- Todas las contraseñas van a estar hasheadas con SHA-256
/*+-----------------------------------------------------------------------------------------------------+*/
/*+-----------------------------------------------------------------------------------------------------+*/

-- Usuario app (puedes acceder desde donde quiera)
CREATE USER 'app'@'%' IDENTIFIED WITH caching_sha2_password BY 'app1234_';

-- Usuario Dashboard (puede acceder desde donde quiera)
CREATE USER 'dashboard'@'%' IDENTIFIED WITH caching_sha2_password BY 'dashboard1234_';

-- Usuario backup local (solo puede acceder localmente)
CREATE USER 'backup'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'backup1234_';

-- Usuario ADMIN local (solo puede acceder localmente)
CREATE USER 'admin'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'dba1234_';

/*+-----------------------------------------------------------------------------------------------------+*/
/*+-----------------------------------------------------------------------------------------------------+*/


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
-- Permisos para dashboard, solo lectura en todas las tablas
/*+-----------------------------------------------------------------------------------------------------+*/

GRANT SELECT ON rideHailing.* TO 'dashboard'@'%';

/*+-----------------------------------------------------------------------------------------------------+*/
-- PERMISOS ADMIN
-- Permiso completo para el ADMIN solo en localhost
/*+-----------------------------------------------------------------------------------------------------+*/
GRANT ALL PRIVILEGES ON rideHailing.* TO 'admin'@'localhost';

/*+-----------------------------------------------------------------------------------------------------+*/
-- PERMISOS BACKUP
-- Permiso de lectura de todas las tablas, bloqueo de tablas para que no puedan otros modificar tablas mientras
-- se hace la copia de seguridad, y ver las vistas para backup solo en localhost
/*+-----------------------------------------------------------------------------------------------------+*/

GRANT SELECT, LOCK TABLES, SHOW VIEW ON rideHailing.* TO 'backup'@'localhost';

/*+-----------------------------------------------------------------------------------------------------+*/
-- ROLES
-- Rol Lectura  => Permite consultar datos sin poder modificarlos. Asignado a usuarios como dashboard.
-- Rol Escritura => Permite insertar, actualizar y eliminar datos. Asignado a usuarios como app.
/*+-----------------------------------------------------------------------------------------------------+*/
CREATE ROLE 'rol_lectura', 'rol_escritura';

-- Permisos para rol_lectura, solo lectura en todas las tablas y rol_escritura puede insertar y actualizar en viaje solo
GRANT SELECT ON rideHailing.* TO 'rol_lectura';
GRANT INSERT, UPDATE ON rideHailing.viaje  TO 'rol_escritura';

-- Asignamos los roles a los usuarios correspondientes
GRANT 'rol_lectura'  TO 'dashboard'@'%';
GRANT 'rol_escritura' TO 'app'@'%';

-- Activamos los roles por defecto para que se apliquen automáticamente al conectarse
SET DEFAULT ROLE ALL TO 'app'@'%';
SET DEFAULT ROLE ALL TO 'dashboard'@'%';

-- Aplicamos los permisos
FLUSH PRIVILEGES;

-- Verificamos los permisos asignados a cada usuario
SELECT user, host, plugin, account_locked, password_expired
FROM mysql.user
WHERE user IN ('app', 'dashboard', 'backup', 'dba');

SHOW GRANTS FOR 'app'@'%';
SHOW GRANTS FOR 'dashboard'@'%';

-- Ver las cuentas que tengan acceso desde cualquier host
SELECT user, host FROM mysql.user WHERE host = '%';

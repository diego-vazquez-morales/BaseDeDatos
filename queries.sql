-- Active: 1777132168327@@127.0.0.1@3306@rideHailing

USE rideHailing;

/*+-----------------------------------------------------------------------------------------------------+*/
-- TRIGGER: solo un conductor puede aceptar una oferta
-- Este trigger se ejecuta antes de cada UPDATE en oferta_conductor.
-- Si alguien intenta poner decision='aceptada', valida que no exista ya
-- otro conductor con decision='aceptada' para la misma oferta.
-- Si ya existe, lanza un error de negocio (SQLSTATE 45000).
/*+-----------------------------------------------------------------------------------------------------+*/

DROP TRIGGER IF EXISTS trg_oferta_conductor_unica_aceptacion;

DELIMITER $$

CREATE TRIGGER trg_oferta_conductor_unica_aceptacion
BEFORE UPDATE ON oferta_conductor
FOR EACH ROW
BEGIN
    IF NEW.decision = 'aceptada' THEN
        IF EXISTS (
            SELECT 1
            FROM oferta_conductor
            WHERE id_oferta = NEW.id_oferta
              AND decision = 'aceptada'
              AND id_conductor <> NEW.id_conductor
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe un conductor que ha aceptado esta oferta';
        END IF;
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM rideHailing;

/*+-----------------------------------------------------------------------------------------------------+*/
-- ALTA DE NUEVO RIDER (usuario + rider)
-- Primero insertamos en usuario (datos comunes), luego en rider (rol especifico).
-- Eliminamos previamente el usuario demo para que el script sea re-ejecutable
-- sin errores por duplicado de email o telefono.
/*+-----------------------------------------------------------------------------------------------------+*/

-- Lo eliminamos en caso que exista cuando eliminas el usuario por el cascade 
-- se elimina automaticamente de la tabla rider
DELETE FROM usuario
WHERE email = 'rider.demo@email.com';

START TRANSACTION;

-- Creamos un nuevo usuario
INSERT INTO usuario (nombre, email, telefono, password)
VALUES ('Rider Demo', 'rider.demo@email.com', '699000050', 'hash_rider_demo');

-- Guardamos el id generado para reutilizarlo en los siguientes inserts
SET @id_usuario_demo := LAST_INSERT_ID();

-- Alta en rider enlazando por FK con usuario
INSERT INTO rider (id_usuario, metodo_pago)
VALUES (@id_usuario_demo, 'tarjeta');

-- Id del rider recien creado
SET @id_rider_demo := LAST_INSERT_ID();

COMMIT;

-- Mostramos el nuevo usuario creado
SELECT r.id_rider, u.id_usuario, u.nombre, u.email, u.estado
FROM rider r
JOIN usuario u ON u.id_usuario = r.id_usuario
WHERE r.id_rider = @id_rider_demo;

/*+-----------------------------------------------------------------------------------------------------+*/
-- 3) CREAR VIAJE + OFERTA Y DISTRIBUIR A CONDUCTORES ACTIVOS
-- Flujo: viaje solicitado -> oferta pendiente -> reparto a conductores activos.
-- Se guardan ids intermedios en variables para evitar hardcodear ids.
/*+-----------------------------------------------------------------------------------------------------+*/

-- Usamos la tarifa 1 para el ejemplo de demo
SET @id_tarifa_demo := 1;

-- Insertamos un nuevo viaje
INSERT INTO viaje (
    id_rider,
    id_tarifa,
    origen_lat,
    origen_lon,
    destino_lat,
    destino_lon,
    estado
)
VALUES (
    @id_rider_demo,
    @id_tarifa_demo,
    40.416775,
    -3.703790,
    40.420000,
    -3.707000,
    'solicitado'
);

SET @id_viaje_demo := LAST_INSERT_ID();

-- Creamos la oferta asociada al viaje
INSERT INTO oferta (id_viaje, estado)
VALUES (@id_viaje_demo, 'pendiente');

SET @id_oferta_demo := LAST_INSERT_ID();

-- Repartimos la oferta a todos los conductores cuyo usuario este activo
INSERT INTO oferta_conductor (id_oferta, id_conductor)
SELECT @id_oferta_demo, c.id_conductor
FROM conductor c
JOIN usuario u ON u.id_usuario = c.id_usuario
WHERE u.estado = 'activo';


-- Verificamos que la oferta se ha distribuido correctamente
SELECT * FROM oferta_conductor WHERE id_oferta = @id_oferta_demo ORDER BY id_conductor;

/*+-----------------------------------------------------------------------------------------------------+*/
-- ACEPTACION CORRECTA DE OFERTA 
-- Se bloquea la fila con FOR UPDATE para evitar condiciones de carrera.
-- Un conductor acepta el viaje el estado del viaje pasa a aceptado y luego se pone en rechazado para el
-- resto de conductores
-- Se registra el evento en evento_viaje para auditoria.
/*+-----------------------------------------------------------------------------------------------------+*/

-- Elegimos el conductor activo de menor id para la demo
SET @id_conductor_1 := (
    SELECT MIN(c.id_conductor)
    FROM conductor c
    JOIN usuario u ON u.id_usuario = c.id_usuario
    WHERE u.estado = 'activo'
);

START TRANSACTION;

-- Bloqueo de la fila que va a aceptar
SELECT id_oferta, id_conductor, decision
FROM oferta_conductor
WHERE id_oferta = @id_oferta_demo
  AND id_conductor = @id_conductor_1
FOR UPDATE;

-- Aceptacion del conductor seleccionado
UPDATE oferta_conductor
SET decision = 'aceptada', respondida_en = NOW()
WHERE id_oferta = @id_oferta_demo
  AND id_conductor = @id_conductor_1
  AND decision = 'pendiente';


-- La oferta global queda aceptada
UPDATE oferta
SET estado = 'aceptada'
WHERE id_oferta = @id_oferta_demo;

-- El viaje queda asignado al conductor que acepto
UPDATE viaje
SET estado = 'aceptado', id_conductor_aceptado = @id_conductor_1
WHERE id_viaje = @id_viaje_demo
  AND estado = 'solicitado';

-- Comprobamos que solo un codunctor tiene la oferta aceptada
SELECT * FROM oferta_conductor WHERE id_oferta = @id_oferta_demo;

-- Rechazo automatico del resto de candidatos pendientes
UPDATE oferta_conductor
SET decision = 'rechazada', respondida_en = NOW()
WHERE id_oferta = @id_oferta_demo
  AND id_conductor <> @id_conductor_1
  AND decision = 'pendiente';

-- Comprobamos que solo un codunctor tiene la oferta aceptada y que el resto han rechazado la oferta
SELECT * FROM oferta_conductor WHERE id_oferta = @id_oferta_demo;

-- Registro historico del cambio de estado
INSERT INTO evento_viaje (id_viaje, id_rider, id_conductor, tipo_evento, estado_anterior, estado_nuevo)
VALUES (@id_viaje_demo, @id_rider_demo, @id_conductor_1, 'aceptacion', 'solicitado', 'aceptado');

COMMIT;

/*+-----------------------------------------------------------------------------------------------------+*/
-- PRUEBA DEL TRIGGER
-- Un segundo conductor intenta aceptar la oferta
/*+-----------------------------------------------------------------------------------------------------+*/

SET @id_conductor_2 := (
    SELECT MIN(id_conductor)
    FROM oferta_conductor
    WHERE id_oferta = @id_oferta_demo
      AND id_conductor <> @id_conductor_1
);

-- Descomenta este UPDATE para probar el trigger (debe fallar)
UPDATE oferta_conductor
SET decision = 'aceptada', respondida_en = NOW()
WHERE id_oferta = @id_oferta_demo
AND id_conductor = @id_conductor_2;

/*+-----------------------------------------------------------------------------------------------------+*/
-- CONSULTAS
-- Estas consultas se hacen para comprobar que todos los pasos anteriores se han realizado correctamente
/*+-----------------------------------------------------------------------------------------------------+*/

-- Mostramos que solo hay 1 conductor con el estado de aceptado para @id_oferta_demo
SELECT id_oferta, decision, COUNT(*) AS total
FROM oferta_conductor
WHERE id_oferta = @id_oferta_demo
GROUP BY id_oferta, decision
ORDER BY decision;

-- Estado final del viaje de demo
SELECT v.id_viaje, v.estado, v.id_conductor_aceptado, v.id_rider, v.id_tarifa, v.creado_en
FROM viaje v
WHERE v.id_viaje = @id_viaje_demo;

-- Auditoria del viaje de demo
SELECT e.id_evento, e.tipo_evento, e.estado_anterior, e.estado_nuevo, e.id_conductor, e.creado_en
FROM evento_viaje e
WHERE e.id_viaje = @id_viaje_demo
ORDER BY e.id_evento;


/*+-----------------------------------------------------------------------------------------------------+*/
-- HISTORIAL Y REPORTES
-- Consultas de explotacion para mostrar que el modelo soporta seguimiento operativo.
/*+-----------------------------------------------------------------------------------------------------+*/

-- Ofertas pendientes por conductor (cola de trabajo)
SELECT oc.id_conductor, oc.id_oferta, o.id_viaje, o.creado_en
FROM oferta_conductor oc
JOIN oferta o ON o.id_oferta = oc.id_oferta
WHERE oc.decision = 'pendiente'
ORDER BY oc.id_conductor, o.creado_en;

-- Viajes completos con rider, conductor y vehiculo
-- LEFT JOIN en conductor/vehiculo porque puede haber viajes aun sin asignacion
SELECT v.id_viaje,
       ur.nombre AS rider,
       uc.nombre AS conductor,
       ve.matricula,
       ve.marca,
       ve.modelo,
       v.distancia_km,
       v.precio_total,
       v.estado,
       v.creado_en
FROM viaje v
JOIN rider r ON v.id_rider = r.id_rider
JOIN usuario ur ON ur.id_usuario = r.id_usuario
LEFT JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
LEFT JOIN usuario uc ON uc.id_usuario = c.id_usuario
LEFT JOIN vehiculo ve ON ve.id_conductor = c.id_conductor
ORDER BY v.id_viaje DESC;

-- Vehiculos activos por company (asignaciones vigentes)
SELECT comp.nombre AS company, v.matricula, v.marca, v.modelo, ev.fecha_asignacion
FROM empresa_vehiculo ev
JOIN company comp ON comp.id_company = ev.id_company
JOIN vehiculo v ON v.id_vehiculo = ev.id_vehiculo
WHERE ev.fecha_fin IS NULL
ORDER BY comp.nombre, v.matricula;
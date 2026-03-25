USE rideHailing;

-- Insertar un nuevo rider
INSERT INTO rider (nombre, email) 
VALUES ('Nuevo Rider', 'nuevo@email.com');

-- Ver los riders
SELECT * FROM rider;

-- Eliminar un rider por su ID
DELETE FROM rider
WHERE id_rider = 10;

-- PROCESO PARA UN VIAJE
-- Insertar nuevo rider 
INSERT INTO rider (nombre, email)
VALUES ('Sofia Casado', 'sofiaCasado@gmail.com');

-- Insertar nuevo viaje
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, distancia_km, precio)
VALUES (1, 40.416775, -3.703790, 40.420000, -3.707000, 5.0, 20.00);

-- Hacemos oferta del ultimo viaje insertado
INSERT INTO oferta (id_viaje)
VALUES (LAST_INSERT_ID());

-- Hay que enviar la oferta a los conductores que estén activos dentro de una empresa
INSERT INTO oferta_conductor (id_oferta, id_conductor)
SELECT LAST_INSERT_ID(), id_conductor
FROM conductor
WHERE activo = TRUE;

-- Un conductor solo, acepta la oferta, entonces hacemos una transacción para aceptarla
START TRANSACTION;
-- Cambiamos el estado de la oferta_conductor a aceptada para un conductor específico, por ejemplo del conductor 1
UPDATE oferta_conductor
SET decision = 'aceptada', respondida_en = NOW()
WHERE id_oferta = 1 AND id_conductor = 1;
-- actualizamos el viaje para asignarle el conductor aceptado
UPDATE viaje
SET estado = 'aceptado', id_conductor_aceptado = 1
WHERE id_viaje = 1 AND estado = 'solicitado';
COMMIT;

-- Si el conductor 2 por ejemplo rechaza la oferta, actualizamos el estado a rechazada
UPDATE oferta_conductor
SET decision = 'rechazada', respondida_en = NOW()
WHERE id_oferta = 2 AND id_conductor = 2;

-- Ponemos que el viaje esta en curso
UPDATE viaje
SET estado = 'en_curso'
WHERE id_viaje = 1 AND estado = 'aceptado';

-- Finaliza un viaje
UPDATE viaje
SET estado = 'finalizado'
WHERE id_viaje = 1 AND estado = 'en_curso';

-- Cancela el viaje un rider
UPDATE viaje
SET estado = 'cancelado'
WHERE id_viaje = 1 AND estado IN ('solicitado', 'aceptado');


-- VEMOS LAS OFERTAS PENDIENTES DEL CONDUCTOR 1 ORDENADAS POR FECHA DE CREACION DE LA OFERTA ASCENDENTE
SELECT v.id_viaje, v.origen_lat, v.origen_lon, v.destino_lat, v.destino_lon, v.distancia_km, v.precio, o.creado_en AS oferta_creada
FROM oferta_conductor oc
JOIN oferta o ON oc.id_oferta = o.id_oferta
JOIN viaje v ON o.id_viaje = v.id_viaje
WHERE oc.id_conductor = 1 AND oc.decision = 'pendiente'
ORDER BY o.creado_en ASC;

-- Vemos un viaje completo del rider, el conductor y el vehículo asignado ordenados por fecha de creación del viaje descendente
SELECT v.id_viaje, r.nombre AS rider, c.nombre AS conductor, ve.matricula, ve.marca, ve.modelo, v.distancia_km, v.precio, v.estado, v.creado_en
FROM viaje v
JOIN rider r ON v.id_rider = r.id_rider
LEFT JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
LEFT JOIN vehiculo ve ON c.id_conductor = ve.id_conductor
ORDER BY v.creado_en DESC;

-- Vemos los conductores que están activos en las compañía
SELECT comp.nombre AS company, COUNT(c.id_conductor) AS conductores_activos
FROM company comp
JOIN conductor c ON comp.id_company = c.id_company
WHERE c.activo = TRUE
GROUP BY comp.id_company, comp.nombre
ORDER BY conductores_activos DESC;

-- Vemos el historial de los viajes del rider 1
SELECT v.id_viaje, v.distancia_km, v.precio, v.estado, v.creado_en, c.nombre AS conductor
FROM viaje v
LEFT JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
WHERE v.id_rider = 1
ORDER BY v.creado_en DESC;

-- Vemos los vehículos que están asignados a las compañías
SELECT c.nombre AS company, v.matricula, v.marca, v.modelo, ev.fecha_asignacion
FROM empresa_vehiculo ev
JOIN company c ON ev.id_company = c.id_company
JOIN vehiculo v ON ev.id_vehiculo = v.id_vehiculo
WHERE ev.fecha_fin IS NULL
ORDER BY c.nombre;

-- CONSULTA CON LOCKS POR CONCURRENCIA
-- Hacemos que el conductor 1 intente aceptar la oferta del viaje 3, pero antes bloqueamos la fila para evitar que otro conductor acepte la misma oferta al mismo tiempo
START TRANSACTION;

SELECT id_oferta, id_conductor, decision
FROM oferta_conductor
WHERE id_oferta = 3 AND id_conductor = 1
FOR UPDATE; 
-- Solo se actualiza si sigue pendiente
UPDATE oferta_conductor
SET decision = 'aceptada', respondida_en = NOW()
WHERE id_oferta = 3 AND id_conductor = 1 AND decision = 'pendiente';
UPDATE viaje
SET estado = 'aceptado', id_conductor_aceptado = 1
WHERE id_viaje = (SELECT id_viaje FROM oferta WHERE id_oferta = 3)
  AND estado = 'solicitado';
COMMIT;

-- Desactivar un conductor
UPDATE conductor
SET activo = FALSE
WHERE id_conductor = 3;

-- Ver los que no están activos
SELECT id_conductor, nombre, email, creado_en
FROM conductor
WHERE activo = FALSE;

-- Vemos el plan de ejecución de una consulta para verificar que se está utilizando el índice en la columna estado del viaje
EXPLAIN SELECT * FROM viaje WHERE estado='solicitado';
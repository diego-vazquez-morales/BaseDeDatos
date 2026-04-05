USE rideHailing;

-- Insertar un nuevo rider
INSERT INTO rider (nombre, email) 
VALUES ('Nuevo Rider', 'nuevo@email.com');

-- Ver los riders
SELECT * FROM rider;
SELECT * FROM conductor;
SELECT * FROM viaje;

-- Eliminar un rider por su ID
DELETE FROM rider
WHERE id_rider = 10;

-- ================================================
-- PROCESO PARA UN VIAJE
-- Insertar nuevo rider 
INSERT INTO rider (nombre, email)
VALUES ('Sofia Casado', 'sofiaCasado@gmail.com');

-- Insertar nuevo viaje
-- ditancia_km, duracion_minutos, precio_total NULL hasta que se finalice el viaje
INSERT INTO viaje (id_rider, id_tarifa, origen_lat, origen_lon, destino_lat, destino_lon)
VALUES (1, 1, 40.416775, -3.703790, 40.420000, -3.707000);

-- Hacemos oferta del ultimo viaje insertado
INSERT INTO oferta (id_viaje, estado)
VALUES (LAST_INSERT_ID(), 'pendiente');

-- Hay que enviar la oferta a los conductores que estén activos dentro de una empresa
INSERT INTO oferta_conductor (id_oferta, id_conductor)
SELECT LAST_INSERT_ID(), id_conductor
FROM conductor
WHERE activo = TRUE;

-- ================================================
-- Un conductor solo, acepta la oferta, entonces hacemos una transacción para aceptarla
START TRANSACTION;

-- Bloqueamos la fila del conductor que intenta aceptar
SELECT id_oferta, id_conductor, decision
FROM oferta_conductor
WHERE id_oferta = 1 AND id_conductor = 1
FOR UPDATE;

-- Cambiamos el estado de la oferta_conductor a aceptada para un conductor específico, por ejemplo del conductor 1
UPDATE oferta_conductor
SET decision = 'aceptada', respondida_en = NOW()
WHERE id_oferta = 1 AND id_conductor = 1 AND decision = 'pendiente';

-- actualizamos el viaje para asignarle el conductor aceptado
UPDATE viaje
SET estado = 'aceptado', id_conductor_aceptado = 1
WHERE id_viaje = (SELECT id_viaje FROM oferta WHERE id_oferta = 1)
  AND estado = 'solicitado';

-- Rechazo de oferta al resto de conductores pendientes
UPDATE oferta_conductor
SET decision = 'rechazada', respondida_en = NOW()
WHERE id_oferta = 1 AND id_conductor != 1 AND decision = 'pendiente';

-- Registro de evento de aceptación de oferta
INSERT INTO evento_viaje(id_viaje, id_conductor, tipo_evento, estado_anterior, estado_nuevo)
VALUES ((SELECT id_viaje FROM oferta WHERE id_oferta = 1),
        1,
        'aceptacion',
        'solicitado',
        'aceptado');
COMMIT;

-- RECHAZO DE OFERTA POR OTRO CONDUCTOR
START TRANSACTION;
UPDATE oferta_conductor
SET decision = 'rechazada', respondida_en = NOW()
WHERE id_oferta = 1 AND id_conductor = 2 AND decision = 'pendiente';
COMMIT;

-- ================================================
-- VIAJE

-- Ponemos que el viaje esta en curso
START TRANSACTION;
UPDATE viaje
SET estado = 'en_curso'
WHERE id_viaje = 1 AND estado = 'aceptado';

INSERT INTO evento_viaje(id_viaje, id_conductor, tipo_evento, estado_anterior, estado_nuevo)
VALUES (1, 1, 'inicio', 'aceptado', 'en_curso');
COMMIT;

-- Finaliza un viaje

START TRANSACTION;

UPDATE viaje v
JOIN tarifa t ON v.id_tarifa = t.id_tarifa
SET v.estado           = 'finalizado',
    v.distancia_km     = 10.5,
    v.duracion_minutos = 25,
    v.precio_total     = t.precio_base + (10.5 * t.euro_por_km) + (25 * t.euro_por_minuto)
WHERE v.id_viaje = 1 AND v.estado = 'en_curso';

INSERT INTO evento_viaje(id_viaje, id_conductor, tipo_evento, estado_anterior, estado_nuevo)
VALUES (1, 1, 'finalizacion', 'en_curso', 'finalizado');

COMMIT;

-- Cancela el viaje un rider
START TRANSACTION;
UPDATE viaje
SET estado = 'cancelado'
WHERE id_viaje = 1 AND estado IN ('solicitado', 'aceptado');

INSERT INTO evento_viaje(id_viaje, id_conductor, tipo_evento, estado_anterior, estado_nuevo)
VALUES (1, 1, 'cancelacion', 'solicitado', 'cancelado');
COMMIT;

-- ================================================
-- VALORACION
START TRANSACTION;
INSERT INTO valoracion (id_viaje, id_rider, id_conductor, puntuacion, comentario)
VALUES (4, 4, 5, 4, 'Excelente viaje, conductor muy amable');

UPDATE conductor
SET valoracion_media = (SELECT AVG(puntuacion) FROM valoracion WHERE id_conductor = 5)
WHERE id_conductor = 5;
COMMIT;

-- CONDUCTORES
-- Desactivar un conductor
UPDATE conductor
SET activo = FALSE
WHERE id_conductor = 3;

-- Ver los que no están activos
SELECT id_conductor, nombre, email, creado_en
FROM conductor
WHERE activo = FALSE;

-- Ver conductores activos por company
SELECT comp.nombre AS company, COUNT(c.id_conductor) AS conductores_activos
FROM company comp
JOIN conductor c ON comp.id_company = c.id_company
WHERE c.activo = TRUE
GROUP BY comp.id_company, comp.nombre
ORDER BY conductores_activos DESC;

-- HISTORIAL

-- VEMOS LAS OFERTAS PENDIENTES DEL CONDUCTOR 1 ORDENADAS POR FECHA DE CREACION DE LA OFERTA ASCENDENTE
SELECT v.id_viaje, v.origen_lat, v.origen_lon, v.destino_lat, v.destino_lon, v.distancia_km, v.precio_total, o.creado_en AS oferta_creada
FROM oferta_conductor oc
JOIN oferta o ON oc.id_oferta = o.id_oferta
JOIN viaje v ON o.id_viaje = v.id_viaje
WHERE oc.id_conductor = 1 AND oc.decision = 'pendiente'
ORDER BY o.creado_en ASC;

-- Vemos un viaje completo del rider, el conductor y el vehículo asignado ordenados por fecha de creación del viaje descendente
SELECT v.id_viaje, r.nombre AS rider, c.nombre AS conductor, ve.matricula, ve.marca, ve.modelo, v.distancia_km, v.precio_total, v.estado, v.creado_en
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
SELECT v.id_viaje, v.distancia_km, v.precio_total, v.estado, v.creado_en, c.nombre AS conductor
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


-- METRICAS POR CONDUCTOR

-- Tasa de aceptacion de ofertas por conductor
SELECT c.nombre AS conductor,
        COUNT(*) AS ofertas_recibidas,
        SUM(CASE WHEN oc.decision = 'aceptada' THEN 1 ELSE 0 END) AS aceptadas,
        ROUND(SUM(CASE WHEN oc.decision = 'aceptada' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tasa_aceptacion_porcntual
        FROM oferta_conductor oc
        JOIN conductor c ON oc.id_conductor = c.id_conductor
        GROUP BY c.id_conductor, c.nombre
        ORDER BY tasa_aceptacion_porcntual DESC;


-- INgresos totales | euro km | euro minuto por conductor
SELECT c.nombre AS conductor,
        COUNT(v.id_viaje) AS viajes_realizados,
        ROUND(SUM(v.precio_total), 2) AS ingresos_totales,
        ROUND(SUM(v.distancia_km), 2) AS km_recorridos,
        ROUND(SUM(v.duracion_minutos), 2) AS minutos_conducidos,
        ROUND(SUM(v.precio_total) / NULLIF(SUM(v.distancia_km), 0), 4) AS euro_por_km,
        ROUND(SUM(v.precio_total) / NULLIF(SUM(v.duracion_minutos), 0), 4) AS euro_por_minuto
FROM viaje v
JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
WHERE v.estado = 'finalizado'
GROUP BY v.id_conductor_aceptado, c.nombre
ORDER BY ingresos_totales DESC;

-- Tiempo medio y km medio de viajes hechos por conductor
SELECT c.nombre AS conductor,
        ROUND(AVG(v.distancia_km), 2) AS distancia_media_km,
        ROUND(AVG(v.duracion_minutos), 2) AS duracion_media_minutos
FROM viaje v
JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
WHERE v.estado = 'finalizado'
GROUP BY v.id_conductor_aceptado, c.nombre;


-- METRICAS POR COMPANY

-- Tasa de aceptacion de ofertas por company
SELECT comp.nombre AS company,
        COUNT(*) AS ofertas_recibidas,
        SUM(CASE WHEN oc.decision = 'aceptada' THEN 1 ELSE 0 END) AS aceptadas,
        ROUND(SUM(CASE WHEN oc.decision = 'aceptada' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tasa_aceptacion_porcntual
FROM oferta_conductor oc
JOIN conductor c ON oc.id_conductor = c.id_conductor
JOIN company comp ON c.id_company = comp.id_company
GROUP BY comp.id_company, comp.nombre
ORDER BY tasa_aceptacion_porcntual DESC;

-- INgresos totales | euro km | euro minuto por company
SELECT comp.nombre AS company,
        COUNT(v.id_viaje) AS viajes_realizados,
        ROUND(SUM(v.precio_total), 2) AS ingresos_totales,
        ROUND(SUM(v.distancia_km), 2) AS km_recorridos,
        ROUND(SUM(v.duracion_minutos), 2) AS minutos_conducidos,
        ROUND(SUM(v.precio_total) / NULLIF(SUM(v.distancia_km), 0), 4) AS euro_por_km,
        ROUND(SUM(v.precio_total) / NULLIF(SUM(v.duracion_minutos), 0), 4) AS euro_por_minuto
FROM viaje v
JOIN conductor c ON v.id_conductor_aceptado = c.id_conductor
JOIN company comp ON c.id_company = comp.id_company
WHERE v.estado = 'finalizado'
GROUP BY comp.id_company, comp.nombre
ORDER BY ingresos_totales DESC;


-- Valoracion media por company
SELECT comp.nombre AS company,
        ROUND(AVG(val.puntuacion), 2) AS valoracion_media
FROM valoracion val
JOIN conductor c ON val.id_conductor = c.id_conductor
JOIN company comp ON c.id_company = comp.id_company
GROUP BY comp.id_company, comp.nombre
ORDER BY valoracion_media DESC;

-- CONSULTA CON LOCKS POR CONCURRENCIA
-- Hacemos que el conductor 1 intente aceptar la oferta del viaje 3, pero antes bloqueamos la fila para evitar que otro conductor acepte la misma oferta al mismo tiempo
--START TRANSACTION;

--SELECT id_oferta, id_conductor, decision
--FROM oferta_conductor
--WHERE id_oferta = 3 AND id_conductor = 1
--FOR UPDATE; 
-- Solo se actualiza si sigue pendiente
--UPDATE oferta_conductor
--SET decision = 'aceptada', respondida_en = NOW()
--      WHERE id_oferta = 3 AND id_conductor = 1 AND decision = 'pendiente';
--UPDATE viaje
--SET estado = 'aceptado', id_conductor_aceptado = 1
--WHERE id_viaje = (SELECT id_viaje FROM oferta WHERE id_oferta = 3)
  --AND estado = 'solicitado';
--COMMIT;



-- Vemos el plan de ejecución de una consulta para verificar que se está utilizando el índice en la columna estado del viaje
EXPLAIN SELECT * FROM viaje WHERE estado='solicitado';
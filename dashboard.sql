USE rideHailing;

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

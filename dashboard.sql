
--aqui van las consultas para los 2 dashboards de la plataforma:
--Dashboard de métricas de base de datos para monitorización.
--Dashboard de métricas de negocio (viajes por hora, ofertas aceptadas, etc.).





-- 1.--Dashboard de métricas de base de datos para monitorización.

--Metricas de conexiones en la base de dato----

-- Conexiones actuales
SHOW STATUS LIKE 'Threads_connected';

-- Máximo de conexiones alcanzado
SHOW STATUS LIKE 'Max_used_connections';

-- Límite configurado si se acerca  a este limite hay riego de rechazo 
SHOW VARIABLES LIKE 'max_connections';

-- Conexiones rechazadas porque supera el maximo
SHOW STATUS LIKE 'Connection_errors_max_connections';



--METRICAS DE QUERIES--

--total de queries ejecutadas desde q arranca el servidor
SHOW STATUS LIKE 'Queries';

-- total de select realizados
SHOW STATUS LIKE 'Com_select';
-- total de insert realizados
SHOW STATUS LIKE 'Com_insert';
-- total de update realizados
SHOW STATUS LIKE 'Com_update';
-- total de delete realizados
SHOW STATUS LIKE 'Com_delete';

--total de queries lentas son las que tardan mas del tiempo configurado (long_query_time)
SHOW STATUS LIKE 'Slow_queries';


--METRICAS DE INNOBD (BUFFER POOL)--

-- Tamaño del buffer pool en bytes
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

--total de paginas usadas en el boofer pool
SHOW STATUS LIKE 'Innodb_buffer_pool_pages_total';
--total de paginas libres en el buufer pool
SHOW STATUS LIKE 'Innodb_buffer_pool_pages_free';
--total de paginas usadas en memoria pero no escritas en el disco
SHOW STATUS LIKE 'Innodb_buffer_pool_pages_dirty';

-- Hit ratio es el porecntaje de datos q se leen desde memoria y no en el disco en caso de q sea menos a 95 significa que lee mucho de disco y no de memoria
-- Hit ratio = (read_requests - reads) / read_requests * 100
SELECT
  (1 - (
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') /
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
  )) * 100 AS buffer_pool_hit_ratio;

--METRICAS DE BLOQUEO--

-- cuantas veces tuvo q esperar una transaccion por un bloqueo de una fila
SHOW STATUS LIKE 'Innodb_row_lock_waits';
--tiempo medio q se espero en milisegundos 
SHOW STATUS LIKE 'Innodb_row_lock_time_avg';

-- total de deadlocks ocurridos debe ser 0
SHOW STATUS LIKE 'Innodb_deadlocks';

-- trasnsacciones abiertas en este instante
SELECT * FROM information_schema.INNODB_TRX;



--QUERIES LENTAS--

--muestra las 10 queries q fueron mas lentas ordenadas
SELECT * FROM sys.statement_analysis ORDER BY total_latency DESC LIMIT 10;
--que locks estan esperando y que es lo q los bloquea
SELECT * FROM performance_schema.data_lock_waits LIMIT 50;

--PREGUNTAR EQUPO SI PREGIEREN ESTA EN VEZ DE LA DE ARRIBA ESTA ES MAS ESPECIFICA Y NO SE APOYA EN UN * SINO COGE LO UNICO ESENCIA EN EL SELECT
SELECT
    query,
    exec_count        AS ejecuciones,
    avg_latency       AS media,
    max_latency       AS maximo,
    total_latency     AS total
FROM sys.statement_analysis
ORDER BY total_latency DESC
LIMIT 10;

--MANTENIMIENTO DE INDICES--
--indices declarados en la bbdd pero no usados nunca
SELECT * FROM sys.schema_unused_indexes;
--indices que estan duplicados y no apartan nada nuevo
SELECT * FROM sys.schema_redundant_indexes;


--2.Dashboard de métricas de negocio (viajes por hora, ofertas aceptadas, etc.).


-- VIAJES POR HORA
-- Agrupa los viajes por hora del día para ver en qué tramos
-- hay más demanda. Útil para ajustar flotas y turnos de conductores.

SELECT
    HOUR(creado_en)       AS hora_del_dia,
    COUNT(*)              AS total_viajes,
    SUM(precio_total)           AS ingresos_totales,
    ROUND(AVG(precio_total), 2) AS precio_medio
FROM viaje
WHERE creado_en >= NOW() - INTERVAL 7 DAY  -- última semana
GROUP BY HOUR(creado_en)
ORDER BY hora_del_dia;



-- ESTADO ACTUAL DE LOS VIAJES (distribución por estado)
-- Muestra cuántos viajes hay en cada estado en este momento.
-- Permite detectar si hay muchos viajes "solicitados" sin aceptar
-- (puede indicar falta de conductores disponibles).

SELECT
    estado,
    COUNT(*) AS total
FROM viaje
GROUP BY estado
ORDER BY total DESC;



-- OFERTAS ACEPTADAS VS RECHAZADAS VS PENDIENTES
-- Muestra el volumen de decisiones por tipo para detectar
-- si muchas ofertas quedan sin responder o son rechazadas.
-- Basado en: 07_monitorizacion.md - QPS y métricas de negocio

SELECT
    decision,
    COUNT(*) AS total
FROM oferta_conductor
GROUP BY decision
ORDER BY total DESC;



-- TASA DE ACEPTACIÓN POR CONDUCTOR
-- Calcula el porcentaje de ofertas que cada conductor acepta.
-- Un conductor con tasa muy baja puede estar inactivo o rechazando
-- demasiados viajes.
SELECT
    c.id_conductor,
    u.nombre                                                              AS conductor,
    COUNT(oc.id_oferta)                                                   AS total_ofertas_recibidas,
    SUM(oc.decision = 'aceptada')                                         AS aceptadas,
    SUM(oc.decision = 'rechazada')                                        AS rechazadas,
    ROUND(SUM(oc.decision = 'aceptada') / COUNT(oc.id_oferta) * 100, 2)  AS tasa_aceptacion_pct
FROM conductor c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN oferta_conductor oc ON c.id_conductor = oc.id_conductor
GROUP BY c.id_conductor, u.nombre
ORDER BY tasa_aceptacion_pct DESC;



-- TASA DE ACEPTACIÓN POR COMPANY
-- Igual que la anterior pero agrupado a nivel de empresa.
-- Permite comparar qué compañías tienen conductores más activos.

SELECT
    co.id_company,
    co.nombre                                                             AS company,
    COUNT(oc.id_oferta)                                                   AS total_ofertas,
    SUM(oc.decision = 'aceptada')                                         AS aceptadas,
    SUM(oc.decision = 'rechazada')                                        AS rechazadas,
    ROUND(SUM(oc.decision = 'aceptada') / COUNT(oc.id_oferta) * 100, 2)  AS tasa_aceptacion_pct
FROM company co
JOIN conductor c  ON co.id_company  = c.id_company
JOIN oferta_conductor oc ON c.id_conductor = oc.id_conductor
GROUP BY co.id_company, co.nombre
ORDER BY tasa_aceptacion_pct DESC;


--MIRAR DAVID
-- INGRESOS POR CONDUCTOR
-- Suma los precios de todos los viajes finalizados de cada conductor.
-- También calcula euros/km como métrica de eficiencia.
-- Nota: euros/minuto no es calculable porque la tabla viaje no tiene
-- campos de inicio/fin de viaje — se necesitaría añadir inicio_en y
-- fin_en a la tabla viaje para implementarlo.

SELECT
    c.id_conductor,
    u.nombre                                                              AS conductor,
    COUNT(v.id_viaje)                                                     AS viajes_finalizados,
    ROUND(SUM(v.precio_total), 2)                                         AS ingresos_totales_eur,
    ROUND(SUM(v.distancia_km), 2)                                         AS km_totales,
    ROUND(AVG(v.distancia_km), 2)                                         AS km_medios_por_viaje,
    ROUND(SUM(v.precio_total) / NULLIF(SUM(v.distancia_km), 0), 2)       AS euros_por_km
FROM conductor c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN viaje v ON c.id_conductor = v.id_conductor_aceptado
WHERE v.estado = 'finalizado'
GROUP BY c.id_conductor, u.nombre
ORDER BY ingresos_totales_eur DESC;



-- INGRESOS POR COMPANY
-- Misma lógica que la anterior pero agrupada por empresa.

SELECT
    co.id_company,
    co.nombre                                                              AS company,
    COUNT(v.id_viaje)                                                      AS viajes_finalizados,
    ROUND(SUM(v.precio_total), 2)                                          AS ingresos_totales_eur,
    ROUND(SUM(v.distancia_km), 2)                                          AS km_totales,
    ROUND(SUM(v.precio_total) / NULLIF(SUM(v.distancia_km), 0), 2)        AS euros_por_km
FROM company co
JOIN conductor c ON co.id_company = c.id_company
JOIN viaje v ON c.id_conductor = v.id_conductor_aceptado
WHERE v.estado = 'finalizado'
GROUP BY co.id_company, co.nombre
ORDER BY ingresos_totales_eur DESC;



-- KILOMETRAJE MEDIO Y PRECIO MEDIO DE LOS VIAJES
-- Métricas globales de los viajes finalizados.
-- Basado en: enunciado - "tiempo medio y kilometraje medio".
-- El tiempo medio no se puede calcular sin campos inicio_en/fin_en.

SELECT
    ROUND(AVG(distancia_km), 2)   AS km_medios,
    ROUND(AVG(precio_total), 2)   AS precio_medio,
    ROUND(MIN(precio_total), 2)   AS precio_minimo,
    ROUND(MAX(precio_total), 2)   AS precio_maximo,
    COUNT(*)                      AS total_viajes_finalizados
FROM viaje
WHERE estado = 'finalizado';


-- TOP CONDUCTORES CON MÁS VIAJES FINALIZADOS
-- Ranking de los conductores más productivos.
SELECT
    u.nombre                AS conductor,
    co.nombre               AS company,
    COUNT(v.id_viaje)       AS viajes_finalizados
FROM viaje v
JOIN conductor c  ON v.id_conductor_aceptado = c.id_conductor
JOIN usuario u    ON c.id_usuario = u.id_usuario
JOIN company co   ON c.id_company = co.id_company
WHERE v.estado = 'finalizado'
GROUP BY c.id_conductor, u.nombre, co.nombre
ORDER BY viajes_finalizados DESC
LIMIT 10;
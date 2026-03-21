USE `ride-hailing`;

-- insertamos 5 empresas
INSERT INTO company (nombre, cif, pais) VALUES
  ('Cabify Spain SL',       'B12345678', 'España'),
  ('Bolt Iberia SL',        'B87654321', 'España'),
  ('Uber Portugal Lda',     'P11223344', 'Portugal'),
  ('Free Now GmbH',         'D99887766', 'Alemania'),
  ('Lyft Europe BV',        'N55443322', 'Países Bajos');

-- insertamos 10 vehiculos
INSERT INTO vehiculo (matricula, modelo, marca, year) VALUES
  ('1234ABC', 'León',       'SEAT',       '2021-01-01'),
  ('5678DEF', 'Golf',       'Volkswagen', '2020-01-01'),
  ('9012GHI', 'Clio',       'Renault',    '2022-01-01'),
  ('3456JKL', 'Prius',      'Toyota',     '2019-01-01'),
  ('7890MNO', '308',        'Peugeot',    '2021-01-01'),
  ('2345PQR', 'Mégane',     'Renault',    '2020-01-01'),
  ('6789STU', 'Ibiza',      'SEAT',       '2022-01-01'),
  ('0123VWX', 'Polo',       'Volkswagen', '2018-01-01'),
  ('4567YZA', 'Model 3',    'Tesla',      '2023-01-01'),
  ('8901BCD', 'Corolla',    'Toyota',     '2021-01-01');

-- insertamos 10 conductores 2 por empresa
INSERT INTO conductor (nombre, licencia, rating, activo, company_id, vehiculo_id) VALUES
  ('Carlos García',     'LIC-001', 4.85, TRUE, 1, 1),
  ('Ana Martínez',      'LIC-002', 4.92, TRUE, 1, 2),
  ('Pedro López',       'LIC-003', 4.70, TRUE, 2, 3),
  ('Lucía Fernández',   'LIC-004', 4.88, TRUE, 2, 4),
  ('Miguel Santos',     'LIC-005', 4.60, TRUE, 3, 5),
  ('Sofia Pereira',     'LIC-006', 4.95, TRUE, 3, 6),
  ('Klaus Müller',      'LIC-007', 4.75, TRUE, 4, 7),
  ('Hanna Schmidt',     'LIC-008', 4.80, TRUE, 4, 8),
  ('James Wilson',      'LIC-009', 4.65, TRUE, 5, 9),
  ('Emma Johnson',      'LIC-010', 4.90, TRUE, 5, 10);

-- insertamos 20 riders
INSERT INTO rider (nombre, email, telefono, rating) VALUES
  ('Laura Torres',      'laura.torres@email.com',    '+34600000001', 4.80),
  ('Diego Ruiz',        'diego.ruiz@email.com',      '+34600000002', 4.60),
  ('Marta Sánchez',     'marta.sanchez@email.com',   '+34600000003', 4.90),
  ('Javier Moreno',     'javier.moreno@email.com',   '+34600000004', 4.70),
  ('Elena Jiménez',     'elena.jimenez@email.com',   '+34600000005', 4.85),
  ('Pablo Díaz',        'pablo.diaz@email.com',      '+34600000006', 4.55),
  ('Carmen Álvarez',    'carmen.alvarez@email.com',  '+34600000007', 4.75),
  ('Sergio Romero',     'sergio.romero@email.com',   '+34600000008', 4.95),
  ('Isabel Navarro',    'isabel.navarro@email.com',  '+34600000009', 4.65),
  ('Raúl Herrera',      'raul.herrera@email.com',    '+34600000010', 4.80),
  ('Nuria Castro',      'nuria.castro@email.com',    '+34600000011', 4.70),
  ('Antonio Gil',       'antonio.gil@email.com',     '+34600000012', 4.50),
  ('Silvia Ortega',     'silvia.ortega@email.com',   '+34600000013', 4.88),
  ('Roberto Vega',      'roberto.vega@email.com',    '+34600000014', 4.60),
  ('Pilar Molina',      'pilar.molina@email.com',    '+34600000015', 4.92),
  ('Andrés Delgado',    'andres.delgado@email.com',  '+34600000016', 4.73),
  ('Cristina Flores',   'cristina.flores@email.com', '+34600000017', 4.85),
  ('Fernando Ramos',    'fernando.ramos@email.com',  '+34600000018', 4.40),
  ('Patricia León',     'patricia.leon@email.com',   '+34600000019', 4.78),
  ('Marcos Iglesias',   'marcos.iglesias@email.com', '+34600000020', 4.66);

-- insertamos 30 viajes en distintos estados, todos localizados en la zona de madrid
INSERT INTO viaje (origen_latitud, origen_longitud, destino_latitud, destino_longitud,
                   estado, km, duracion_min, precio_km, precio_minuto,
                   rider_id, conductor_id, creado_en, actualizado_en) VALUES
-- Finalizados (tienen conductor y métricas)
  (40.416775, -3.703790, 40.453060, -3.688344, 'finalizado', 5.2,  12.0, 0.350, 0.180, 1,  1,  NOW() - INTERVAL 5 DAY,  NOW() - INTERVAL 5 DAY),
  (40.420000, -3.700000, 40.440000, -3.670000, 'finalizado', 3.8,  9.5,  0.350, 0.180, 2,  2,  NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
  (40.430000, -3.710000, 40.460000, -3.690000, 'finalizado', 6.1,  15.0, 0.350, 0.180, 3,  3,  NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
  (40.415000, -3.695000, 40.425000, -3.665000, 'finalizado', 4.4,  11.0, 0.350, 0.180, 4,  4,  NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
  (40.422000, -3.705000, 40.455000, -3.715000, 'finalizado', 7.3,  18.0, 0.350, 0.180, 5,  5,  NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
  (40.418000, -3.700000, 40.435000, -3.680000, 'finalizado', 2.9,  8.0,  0.350, 0.180, 6,  6,  NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (40.425000, -3.698000, 40.448000, -3.672000, 'finalizado', 5.8,  14.0, 0.350, 0.180, 7,  7,  NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (40.412000, -3.706000, 40.430000, -3.688000, 'finalizado', 3.2,  9.0,  0.350, 0.180, 8,  8,  NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (40.419000, -3.701000, 40.450000, -3.695000, 'finalizado', 6.7,  16.5, 0.350, 0.180, 9,  9,  NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (40.427000, -3.699000, 40.442000, -3.675000, 'finalizado', 4.1,  10.5, 0.350, 0.180, 10, 10, NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (40.416000, -3.703000, 40.438000, -3.682000, 'finalizado', 3.5,  9.0,  0.380, 0.190, 11, 1,  NOW() - INTERVAL 6 HOUR, NOW() - INTERVAL 6 HOUR),
  (40.421000, -3.707000, 40.452000, -3.693000, 'finalizado', 5.5,  13.5, 0.380, 0.190, 12, 2,  NOW() - INTERVAL 5 HOUR, NOW() - INTERVAL 5 HOUR),
  (40.414000, -3.694000, 40.429000, -3.668000, 'finalizado', 4.0,  10.0, 0.380, 0.190, 13, 3,  NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 4 HOUR),
  (40.423000, -3.702000, 40.444000, -3.678000, 'finalizado', 6.2,  15.5, 0.380, 0.190, 14, 4,  NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 3 HOUR),
  (40.417000, -3.708000, 40.436000, -3.685000, 'finalizado', 3.1,  8.5,  0.380, 0.190, 15, 5,  NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 2 HOUR),
-- En curso (tienen conductor, sin métricas aún)
  (40.420000, -3.710000, 40.458000, -3.700000, 'en_curso',   NULL, NULL, NULL,  NULL,  16, 6,  NOW() - INTERVAL 10 MINUTE, NOW() - INTERVAL 10 MINUTE),
  (40.413000, -3.696000, 40.431000, -3.671000, 'en_curso',   NULL, NULL, NULL,  NULL,  17, 7,  NOW() - INTERVAL 8 MINUTE,  NOW() - INTERVAL 8 MINUTE),
-- Aceptados (tienen conductor asignado, aún no iniciados)
  (40.426000, -3.704000, 40.449000, -3.679000, 'aceptado',   NULL, NULL, NULL,  NULL,  18, 8,  NOW() - INTERVAL 5 MINUTE,  NOW() - INTERVAL 5 MINUTE),
  (40.418000, -3.697000, 40.437000, -3.683000, 'aceptado',   NULL, NULL, NULL,  NULL,  19, 9,  NOW() - INTERVAL 3 MINUTE,  NOW() - INTERVAL 3 MINUTE),
-- Solicitados (sin conductor aún)
  (40.415000, -3.709000, 40.453000, -3.691000, 'solicitado', NULL, NULL, NULL,  NULL,  20, NULL, NOW() - INTERVAL 1 MINUTE, NOW() - INTERVAL 1 MINUTE),
  (40.422000, -3.700000, 40.441000, -3.674000, 'solicitado', NULL, NULL, NULL,  NULL,  1,  NULL, NOW() - INTERVAL 2 MINUTE, NOW() - INTERVAL 2 MINUTE),
  (40.419000, -3.703000, 40.456000, -3.696000, 'solicitado', NULL, NULL, NULL,  NULL,  2,  NULL, NOW(),                      NOW()),
-- Cancelados
  (40.424000, -3.706000, 40.446000, -3.680000, 'cancelado',  NULL, NULL, NULL,  NULL,  3,  NULL, NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (40.411000, -3.695000, 40.428000, -3.669000, 'cancelado',  NULL, NULL, NULL,  NULL,  4,  NULL, NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY);


-- ofertas una por viaje, viajes 1-22 tienen oferta
INSERT INTO oferta (estado, creada_en, cerrada_en, viaje_id) VALUES
  ('cerrada',  NOW() - INTERVAL 5 DAY,    NOW() - INTERVAL 5 DAY,    1),
  ('cerrada',  NOW() - INTERVAL 4 DAY,    NOW() - INTERVAL 4 DAY,    2),
  ('cerrada',  NOW() - INTERVAL 4 DAY,    NOW() - INTERVAL 4 DAY,    3),
  ('cerrada',  NOW() - INTERVAL 3 DAY,    NOW() - INTERVAL 3 DAY,    4),
  ('cerrada',  NOW() - INTERVAL 3 DAY,    NOW() - INTERVAL 3 DAY,    5),
  ('cerrada',  NOW() - INTERVAL 2 DAY,    NOW() - INTERVAL 2 DAY,    6),
  ('cerrada',  NOW() - INTERVAL 2 DAY,    NOW() - INTERVAL 2 DAY,    7),
  ('cerrada',  NOW() - INTERVAL 1 DAY,    NOW() - INTERVAL 1 DAY,    8),
  ('cerrada',  NOW() - INTERVAL 1 DAY,    NOW() - INTERVAL 1 DAY,    9),
  ('cerrada',  NOW() - INTERVAL 1 DAY,    NOW() - INTERVAL 1 DAY,    10),
  ('cerrada',  NOW() - INTERVAL 6 HOUR,   NOW() - INTERVAL 6 HOUR,   11),
  ('cerrada',  NOW() - INTERVAL 5 HOUR,   NOW() - INTERVAL 5 HOUR,   12),
  ('cerrada',  NOW() - INTERVAL 4 HOUR,   NOW() - INTERVAL 4 HOUR,   13),
  ('cerrada',  NOW() - INTERVAL 3 HOUR,   NOW() - INTERVAL 3 HOUR,   14),
  ('cerrada',  NOW() - INTERVAL 2 HOUR,   NOW() - INTERVAL 2 HOUR,   15),
  ('cerrada',  NOW() - INTERVAL 10 MINUTE, NOW() - INTERVAL 10 MINUTE, 16),
  ('cerrada',  NOW() - INTERVAL 8 MINUTE,  NOW() - INTERVAL 8 MINUTE,  17),
  ('cerrada',  NOW() - INTERVAL 5 MINUTE,  NOW() - INTERVAL 5 MINUTE,  18),
  ('cerrada',  NOW() - INTERVAL 3 MINUTE,  NOW() - INTERVAL 3 MINUTE,  19),
  ('abierta',  NOW() - INTERVAL 1 MINUTE,  NULL,                       20),
  ('abierta',  NOW() - INTERVAL 2 MINUTE,  NULL,                       21),
  ('abierta',  NOW(),                       NULL,                       22);


-- oferta por conductor
-- el conductor que acepto uno o dos que rechazaron (simulando competencia real)
-- viajes solicitados: conductores con decisión pendiente
INSERT INTO oferta_conductor (oferta_id, conductor_id, decision, enviada_en, respondida_en) VALUES
-- Oferta 1 (viaje 1, aceptó conductor 1)
  (1, 1,  'aceptada',  NOW() - INTERVAL 5 DAY,  NOW() - INTERVAL 5 DAY),
  (1, 2,  'rechazada', NOW() - INTERVAL 5 DAY,  NOW() - INTERVAL 5 DAY),
  (1, 3,  'rechazada', NOW() - INTERVAL 5 DAY,  NOW() - INTERVAL 5 DAY),
-- Oferta 2 (viaje 2, aceptó conductor 2)
  (2, 2,  'aceptada',  NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
  (2, 4,  'rechazada', NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
-- Oferta 3 (viaje 3, aceptó conductor 3)
  (3, 3,  'aceptada',  NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
  (3, 5,  'rechazada', NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
  (3, 1,  'rechazada', NOW() - INTERVAL 4 DAY,  NOW() - INTERVAL 4 DAY),
-- Oferta 4 (viaje 4, aceptó conductor 4)
  (4, 4,  'aceptada',  NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
  (4, 6,  'rechazada', NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
-- Oferta 5 (viaje 5, aceptó conductor 5)
  (5, 5,  'aceptada',  NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
  (5, 7,  'rechazada', NOW() - INTERVAL 3 DAY,  NOW() - INTERVAL 3 DAY),
-- Oferta 6 (viaje 6, aceptó conductor 6)
  (6, 6,  'aceptada',  NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (6, 8,  'rechazada', NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
-- Oferta 7 (viaje 7, aceptó conductor 7)
  (7, 7,  'aceptada',  NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (7, 9,  'rechazada', NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
  (7, 2,  'rechazada', NOW() - INTERVAL 2 DAY,  NOW() - INTERVAL 2 DAY),
-- Oferta 8 (viaje 8, aceptó conductor 8)
  (8, 8,  'aceptada',  NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (8, 10, 'rechazada', NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
-- Oferta 9 (viaje 9, aceptó conductor 9)
  (9, 9,  'aceptada',  NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (9, 1,  'rechazada', NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
-- Oferta 10 (viaje 10, aceptó conductor 10)
  (10, 10, 'aceptada', NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
  (10, 3,  'rechazada',NOW() - INTERVAL 1 DAY,  NOW() - INTERVAL 1 DAY),
-- Ofertas 11-19 (viajes recientes, un solo conductor aceptó)
  (11, 1,  'aceptada',  NOW() - INTERVAL 6 HOUR,  NOW() - INTERVAL 6 HOUR),
  (11, 4,  'rechazada', NOW() - INTERVAL 6 HOUR,  NOW() - INTERVAL 6 HOUR),
  (12, 2,  'aceptada',  NOW() - INTERVAL 5 HOUR,  NOW() - INTERVAL 5 HOUR),
  (13, 3,  'aceptada',  NOW() - INTERVAL 4 HOUR,  NOW() - INTERVAL 4 HOUR),
  (14, 4,  'aceptada',  NOW() - INTERVAL 3 HOUR,  NOW() - INTERVAL 3 HOUR),
  (15, 5,  'aceptada',  NOW() - INTERVAL 2 HOUR,  NOW() - INTERVAL 2 HOUR),
  (16, 6,  'aceptada',  NOW() - INTERVAL 10 MINUTE, NOW() - INTERVAL 10 MINUTE),
  (17, 7,  'aceptada',  NOW() - INTERVAL 8 MINUTE,  NOW() - INTERVAL 8 MINUTE),
  (18, 8,  'aceptada',  NOW() - INTERVAL 5 MINUTE,  NOW() - INTERVAL 5 MINUTE),
  (19, 9,  'aceptada',  NOW() - INTERVAL 3 MINUTE,  NOW() - INTERVAL 3 MINUTE),
-- Ofertas 20-22 (viajes solicitados, conductores pendientes)
  (20, 1,  'pendiente', NOW() - INTERVAL 1 MINUTE, NULL),
  (20, 2,  'pendiente', NOW() - INTERVAL 1 MINUTE, NULL),
  (20, 3,  'pendiente', NOW() - INTERVAL 1 MINUTE, NULL),
  (21, 4,  'pendiente', NOW() - INTERVAL 2 MINUTE, NULL),
  (21, 5,  'pendiente', NOW() - INTERVAL 2 MINUTE, NULL),
  (22, 6,  'pendiente', NOW(),                      NULL),
  (22, 7,  'pendiente', NOW(),                      NULL),
  (22, 8,  'pendiente', NOW(),                      NULL)
USE rideHailing;

-- Company
INSERT INTO company (nombre, cif, pais) VALUES
  ('Cabify Spain SL', 'B12345678', 'España'),
  ('Bolt Iberia SL', 'B87654321', 'España'),
  ('Uber Portugal Lda', 'P11223344', 'Portugal'),
  ('Free Now GmbH', 'D99887766', 'Alemania'),
  ('Lyft Europe BV', 'N55443322', 'Países Bajos');

-- Usuarios (9 riders + 9 conductores = 18 usuarios distintos)
INSERT INTO usuario (nombre, email, telefono, password) VALUES
  ('Juan Pérez',        'juan@email.com',           '600000001', 'hash1'),
  ('María García',      'maria@email.com',           '600000002', 'hash2'),
  ('Carlos Rodríguez',  'carlos@email.com',          '600000003', 'hash3'),
  ('Sofía Fernández',   'sofia@email.com',           '600000004', 'hash4'),
  ('Laura Martínez',    'laura@email.com',           '600000005', 'hash5'),
  ('Antonio Ruiz',      'antonio@email.com',         '600000006', 'hash6'),
  ('Marta Sánchez',     'marta@email.com',           '600000007', 'hash7'),
  ('David Gómez',       'david@email.com',           '600000008', 'hash8'),
  ('Pedro López',       'pedro@email.com',           '600000009', 'hash9'),
  ('Antonio Ruiz C',    'antonioRuiz@email.com',     '600000010', 'hash10'),
  ('Laura Martínez C',  'lauraMartinez@email.com',   '600000011', 'hash11'),
  ('Sofía Fernández C', 'sofiaFernandez@email.com',  '600000012', 'hash12'),
  ('David Gómez C',     'davidGomez@email.com',      '600000013', 'hash13'),
  ('Marta Sánchez C',   'martaSanchez@email.com',    '600000014', 'hash14'),
  ('Juan Pérez C',      'juanPerez@email.com',       '600000015', 'hash15'),
  ('María García C',    'mariaGarcia@email.com',     '600000016', 'hash16'),
  ('Pedro López C',     'pedroLopez@email.com',      '600000017', 'hash17'),
  ('Carlos Rodríguez C','carlosRodriguez@email.com', '600000018', 'hash18');

-- Riders (id_usuario 1-9)
INSERT INTO rider (id_usuario, metodo_pago) VALUES
  (1, 'tarjeta'),
  (2, 'tarjeta'),
  (3, 'efectivo'),
  (4, 'tarjeta'),
  (5, 'paypal'),
  (6, 'tarjeta'),
  (7, 'efectivo'),
  (8, 'tarjeta'),
  (9, 'paypal');

-- Conductores (id_usuario 10-18)
INSERT INTO conductor (id_usuario, id_company, licencia) VALUES
  (10, 1, 'LIC-001'),
  (11, 1, 'LIC-002'),
  (12, 2, 'LIC-003'),
  (13, 3, 'LIC-004'),
  (14, 3, 'LIC-005'),
  (15, 4, 'LIC-006'),
  (16, 4, 'LIC-007'),
  (17, 5, 'LIC-008'),
  (18, 5, 'LIC-009');

-- Vehiculos
INSERT INTO vehiculo (matricula, marca, modelo, anio, id_conductor) VALUES
  ('ABC1234', 'Toyota',     'Prius',   2020, 1),
  ('XYZ5678', 'Tesla',      'Model 3', 2021, 2),
  ('DEF9012', 'Seat',       'Leon',    2019, 3),
  ('GHI3456', 'Renault',    'Clio',    2020, 4),
  ('JKL7890', 'Ford',       'Focus',   2018, 5),
  ('MNO1122', 'Volkswagen', 'Golf',    2022, 6),
  ('PQR3344', 'BMW',        'Serie 3', 2023, 7),
  ('STU5566', 'Honda',      'Civic',   2020, 8),
  ('VWX7788', 'Hyundai',    'Ioniq',   2022, 9);

-- Tarifas por company
INSERT INTO tarifa (id_company, euro_por_km, euro_por_minuto, precio_base) VALUES
  (1, 1.20, 0.20, 2.50),
  (2, 1.10, 0.25, 3.00),
  (3, 1.30, 0.15, 2.00),
  (4, 1.25, 0.18, 2.80),
  (5, 1.15, 0.22, 2.60);

-- Viajes
INSERT INTO viaje (id_rider, id_tarifa, origen_lat, origen_lon, destino_lat, destino_lon, distancia_km, duracion_minutos, estado, precio_total, id_conductor_aceptado) VALUES
  (1, 1, 40.416775, -3.703790, 40.418056, -3.704444, 2.5, 15, 'finalizado', 5.00, 1),
  (2, 2, 40.416775, -3.703790, 40.419000, -3.705000, 3.0, 20, 'finalizado', 6.50, 4),
  (3, 3, 40.416775, -3.703790, 40.420000, -3.706000, 4.0, 25, 'finalizado', 8.00, 4),
  (4, 4, 40.416775, -3.703790, 40.421000, -3.707000, 5.0, 30, 'finalizado', 10.00, 1),
  (5, 5, 40.416775, -3.703790, 40.422000, -3.708000, 6.0, 35, 'cancelado', NULL, NULL),
  (6, 1, 40.416775, -3.703790, 40.423000, -3.709000, NULL, NULL, 'solicitado', NULL, NULL),
  (7, 2, 40.416775, -3.703790, 40.424000, -3.710000, NULL, NULL, 'solicitado', NULL, NULL),
  (8, 3, 40.416775, -3.703790, 40.425000, -3.711000, NULL, NULL, 'solicitado', NULL, NULL),
  (9, 4, 40.416775, -3.703790, 40.426000, -3.712000, NULL, NULL, 'solicitado', NULL, NULL),
  (2, 2, 40.418000, -3.705000, 40.422000, -3.709000, NULL, NULL, 'aceptado',   NULL, 1),
  (3, 3, 40.419000, -3.706000, 40.423000, -3.710000, NULL, NULL, 'en_curso',   NULL, 4);


-- Ofertas
INSERT INTO oferta (id_viaje, estado) VALUES
  (1, 'aceptada'),
  (2, 'aceptada'),
  (3, 'aceptada'),
  (4, 'aceptada'),
  (5, 'expirada'),
  (6, 'pendiente'),
  (7, 'pendiente'),
  (8, 'pendiente'),
  (9, 'pendiente'),
  (10, 'pendiente'),
  (11, 'pendiente');


-- Oferta-Conductor
INSERT INTO oferta_conductor (id_oferta, id_conductor, decision, respondida_en) VALUES
  (1, 1, 'aceptada',  NOW()),
  (1, 2, 'rechazada', NOW()),
  (1, 4, 'rechazada', NOW()),
  (2, 2, 'rechazada', NOW()),
  (2, 4, 'aceptada',  NOW()),
  (2, 5, 'rechazada', NOW()),
  (3, 4, 'aceptada',  NOW()),
  (3, 5, 'rechazada', NOW()),
  (3, 6, 'rechazada', NOW()),
  (4, 1, 'aceptada',  NOW()),
  (4, 2, 'rechazada', NOW()),
  (4, 5, 'rechazada', NOW()),
  (5, 2, 'expirada',  NOW()),
  (5, 1, 'expirada',  NOW()),
  (5, 4, 'expirada',  NOW());

-- Valoraciones
INSERT INTO valoracion (id_viaje, id_rider, id_conductor, puntuacion, comentario) VALUES
  (1, 1, 1, 5, 'Excelente servicio, muy puntual y amable.'),
  (2, 2, 4, 4, 'Buen viaje, aunque el conductor podría ser más amigable.'),
  (3, 3, 4, 5, 'Viaje perfecto, el conductor fue muy profesional.');

-- Actualizar valoracion_media de conductores
UPDATE conductor SET valoracion_media = (SELECT AVG(puntuacion) FROM valoracion WHERE id_conductor = 1) WHERE id_conductor = 1;
UPDATE conductor SET valoracion_media = (SELECT AVG(puntuacion) FROM valoracion WHERE id_conductor = 2) WHERE id_conductor = 2;
UPDATE conductor SET valoracion_media = (SELECT AVG(puntuacion) FROM valoracion WHERE id_conductor = 4) WHERE id_conductor = 4;

-- Empresa-Vehiculo
INSERT INTO empresa_vehiculo (id_company, id_vehiculo, fecha_asignacion, fecha_fin) VALUES
  (1, 1, '2024-01-01', NULL),
  (1, 2, '2024-01-01', NULL),
  (2, 3, '2024-01-01', NULL),
  (3, 4, '2024-01-01', NULL),
  (3, 5, '2024-01-01', NULL),
  (4, 6, '2024-01-01', NULL),
  (4, 7, '2024-01-01', NULL),
  (5, 8, '2024-01-01', NULL),
  (5, 9, '2024-01-01', NULL);

-- EVENTO viaje
INSERT INTO evento_viaje(id_viaje, id_conductor, tipo_evento, estado_anterior, estado_nuevo) VALUES
  (1, 1, 'aceptacion', 'solicitado', 'aceptado'),
  (1, 1, 'inicio', 'aceptado', 'en_curso'),
  (1, 1, 'finalizacion', 'en_curso', 'finalizado'),

  (2, 4, 'aceptacion', 'solicitado', 'aceptado'),
  (2, 4, 'inicio', 'aceptado', 'en_curso'),
  (2, 4, 'finalizacion', 'en_curso', 'finalizado'),

  (3, 4, 'aceptacion', 'solicitado', 'aceptado'),
  (3, 4, 'inicio', 'aceptado', 'en_curso'),
  (3, 4, 'finalizacion', 'en_curso', 'finalizado'),

  (4, 1, 'aceptacion', 'solicitado', 'aceptado'),
  (4, 1, 'inicio', 'aceptado', 'en_curso'),
  (4, 1, 'finalizacion', 'en_curso', 'finalizado'),

  (5, NULL, 'cancelacion', 'solicitado', 'cancelado');


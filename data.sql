USE rideHailing;

-- Company
INSERT INTO company (nombre, cif, pais) VALUES
  ('Cabify Spain SL', 'B12345678', 'España'),
  ('Bolt Iberia SL', 'B87654321', 'España'),
  ('Uber Portugal Lda', 'P11223344', 'Portugal'),
  ('Free Now GmbH', 'D99887766', 'Alemania'),
  ('Lyft Europe BV', 'N55443322', 'Países Bajos');


-- Riders
INSERT INTO rider (nombre, email) VALUES
  ('Juan Pérez', 'juan@email.com'),
  ('María García', 'maria@email.com'),
  ('Carlos Rodríguez', 'carlos@email.com'),
  ('Sofía Fernández', 'sofia@email.com'),
  ('Laura Martínez', 'laura@email.com'),
  ('Antonio Ruiz', 'antonio@email.com'),
  ('Marta Sánchez', 'marta@email.com'),
  ('David Gómez', 'david@email.com'),
  ('Pedro López', 'pedro@email.com');

-- Conductores
INSERT INTO conductor (nombre, email, id_company, activo) VALUES
  ('Antonio Ruiz', 'antonioRuiz@email.com', 1, TRUE),
  ('Laura Martínez', 'lauraMartinez@email.com', 1, TRUE),
  ('Sofía Fernández', 'sofiaFernandez@email.com', 2, FALSE),
  ('David Gómez', 'davidGomez@email.com', 3, TRUE),
  ('Marta Sánchez', 'martaSanchez@email.com', 3, TRUE),
  ('Juan Pérez', 'juanPerez@email.com', 4, TRUE),
  ('María García', 'mariaGarcia@email.com', 4, TRUE),
  ('Pedro López', 'pedroLopez@email.com', 5, TRUE),
  ('Carlos Rodríguez', 'carlosRodriguez@email.com', 5, TRUE);

-- Vehiculos
INSERT INTO vehiculo (matricula, marca, modelo, id_conductor) VALUES
  ('ABC1234', 'Toyota', 'Prius', 1),
  ('XYZ5678', 'Tesla', 'Model 3', 2),
  ('DEF9012', 'Seat', 'Leon', 3),
  ('GHI3456', 'Renault', 'Clio', 4),
  ('JKL7890', 'Ford', 'Focus', 5);


-- Viajes
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, distancia_km, precio) VALUES
  (1, 40.416775, -3.703790, 40.417000, -3.704000, 2.5, 10.00),
  (2, 40.416775, -3.703790, 40.418000, -3.705000, 3.0, 12.00),
  (3, 40.416775, -3.703790, 40.419000, -3.706000, 4.0, 15.00),
  (4, 40.416775, -3.703790, 40.420000, -3.707000, 5.0, 20.00),
  (5, 40.416775, -3.703790, 40.421000, -3.708000, 6.0, 25.00),
  (6, 40.416775, -3.703790, 40.422000, -3.709000, 7.0, 30.00),
  (7, 40.416775, -3.703790, 40.423000, -3.710000, 8.0, 35.00),
  (8, 40.416775, -3.703790, 40.424000, -3.711000, 9.0, 40.00);

-- Ofertas
INSERT INTO oferta (id_viaje) VALUES
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8);

-- Oferta-Conductor
INSERT INTO oferta_conductor (id_oferta, id_conductor) VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8);

-- Viaje-Conductor
INSERT INTO empresa_vehiculo (id_company, id_vehiculo, fecha_asignacion, fecha_fin) VALUES
  (1, 1, '2024-01-01', '2024-06-30'),
  (1, 2, '2024-01-01', NULL),
  (2, 3, '2024-01-01', '2024-12-31'),
  (3, 4, '2024-01-01', NULL),
  (3, 5, '2024-01-01', '2024-12-31'),
  (2, 2, '2024-01-01', NULL),
  (3, 3, '2024-01-01', '2024-12-31'),
  (4, 4, '2024-01-01', NULL),
  (5, 5, '2024-01-01', '2024-12-31');

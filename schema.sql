CREATE DATABASE IF NOT EXISTS `ride-hailing`;

USE DATABASE `ride-hailing`;

CREATE TABLE ride-hailing.company (
    id_comapany BIGINT NOT NULL AUTOINCREMENT,
    nombre      VARCHAR(120)    NOT NULL,
    cif         VARCHAR(20)     NOT NULL,
    pais        VARCHAR(60)     NOT NULL,
    creada_en   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_company),
    UNIQUE KEY uk_cif (cif)
)ENGINE="Innodb";

CREATE TABLE ride-hailing.vehiculo (
    id_vehiculo BIGINT NOT NULL AUTOINCREMENT,
    matricula   VARCHAR(20)     NOT NULL,
    modelo      VARCHAR(80)     NOT NULL,
    marca       VARCHAR(80)     NOT NULL,
    year        DATE NOT NULL,
    creado_en   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vehiculo),
    UNIQUE KEY uk_matricula (matricula)
)ENGINE="Innodb";

CREATE TABLE ride-hailing.conductor (
    id_conductor BIGINT NOT NULL AUTOINCREMENT,
    nombre      VARCHAR(120)    NOT NULL,
    licencia    VARCHAR(40)     NOT NULL,
    rating      FLOAT NOT NULL,
    activo      BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    company_id  INT             NOT NULL REFERENCES company(id_company)  ON DELETE RESTRICT,
    vehiculo_id INT             NOT NULL REFERENCES vehiculo(id_vehiculo) ON DELETE RESTRICT,
    PRIMARY KEY (id_conductor),
    UNIQUE KEY uk_licencia (licencia)
)ENGINE="Innodb";

CREATE TABLE ride-hailing.rider (
    id_rider    BIGINT NOT NULL AUTOINCREMENT,
    nombre      VARCHAR(120)    NOT NULL,
    email       VARCHAR(200)    NOT NULL,
    telefono    VARCHAR(20),
    rating      FLOAT,
    activo      BOOLEAN         NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_rider),
    UNIQUE KEY uk_email (email)
)ENGINE="Innodb";

-- conductor_id es NULL hasta que alguien acepta la oferta
CREATE TABLE ride-hailing.viaje (
    id_viaje BIGINT NOT NULL AUTOINCREMENT,
    origen_latitud      DECIMAL(9,6) NOT NULL,
    origen_longitud     DECIMAL(9,6) NOT NULL,
    destino_latitud     DECIMAL(9,6) NOT NULL,
    destino_longitud DECIMAL(9,6) NOT NULL,
    estado              VARCHAR(20) NOT NULL DEFAULT 'solicitado' CHECK (estado IN ('solicitado','aceptado','en_curso','finalizado','cancelado')),
    km                  DECIMAL(8,3),
    duracion_min DECIMAL(8,2),
    precio_km DECIMAL(9, 6),
    precio_minuto DECIMAL(9, 6),
    creado_en           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_viaje),
    rider_id INT NOT NULL REFERENCES rider(id_rider) ON DELETE RESTRICT,
    conductor_id INT REFERENCES conductor(id_conductor) ON DELETE RESTRICT,
)ENGINE="Innodb";

-- Una oferta por viaje (UNIQUE en viaje_id garantiza la relacion 1:1)
CREATE TABLE ride-hailing.oferta (
    id_oferta BIGINT NOT NULL AUTOINCREMENT,
    estado VARCHAR(20),
    creada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cerrada_en  TIMESTAMP
    viaje_id INT NOT NULL UNIQUE REFERENCES viaje(id_viaje) ON DELETE CASCADE,
    PRIMARY KEY (id_oferta) 
)ENGINE="Innodb";

-- Tabla intermedia del n:n Oferta <-> Conductor
-- El indice unico parcial (en schema de indices) garantiza
-- que solo un conductor pueda tener decision='aceptada' por oferta
CREATE TABLE ride-hailing.oferta_conductor (
    id_oferta_conductor BIGINT NOT NULL,
    oferta_id       INT NOT NULL REFERENCES oferta(id_oferta) ON DELETE CASCADE,
    conductor_id    INT NOT NULL REFERENCES conductor(id_conductor) ON DELETE RESTRICT,
    decision        VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (decision IN ('pendiente','aceptada','rechazada')),
    enviada_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    respondida_en   TIMESTAMP,
    CONSTRAINT uq_oferta_conductor UNIQUE (oferta_id, conductor_id)
    PRIMARY KEY (id_oferta_conductor)
);
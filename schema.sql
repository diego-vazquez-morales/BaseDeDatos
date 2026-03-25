CREATE DATABASE IF NOT EXISTS rideHailing
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE rideHailing;

-- Company
CREATE TABLE company (
    id_company    BIGINT  NOT NULL    AUTO_INCREMENT,
    nombre    VARCHAR(120)    NOT NULL,
    cif   VARCHAR(20)     NOT NULL,
    pais  VARCHAR(60)     NOT NULL,
    creado_en    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_company),
    UNIQUE KEY uk_cif (cif)
) ENGINE=InnoDB;

-- Rider
CREATE TABLE rider (
    id_rider  BIGINT      NOT NULL    AUTO_INCREMENT,
    nombre    VARCHAR(80)     NOT NULL,
    email     VARCHAR(120)    NOT NULL,
    creado_en    TIMESTAMP   DEFAULT     CURRENT_TIMESTAMP,

    PRIMARY KEY (id_rider),
    UNIQUE KEY uk_email (email)
) ENGINE=InnoDB;

-- Conductor
CREATE TABLE conductor (
    id_conductor    BIGINT  NOT NULL    AUTO_INCREMENT,
    nombre  VARCHAR(80)     NOT NULL,
    email   VARCHAR(120)    NOT NULL,
    id_company  BIGINT  NOT NULL,
    activo  BOOLEAN     NOT NULL    DEFAULT TRUE,
    creado_en  TIMESTAMP   DEFAULT     CURRENT_TIMESTAMP,

    PRIMARY KEY (id_conductor),
    UNIQUE KEY uk_email (email),
    FOREIGN KEY (id_company) REFERENCES company(id_company) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Vehiculo
CREATE TABLE vehiculo (
    id_vehiculo     BIGINT  NOT NULL    AUTO_INCREMENT,
    matricula   VARCHAR(16)     NOT NULL,
    marca   VARCHAR(50)     NOT NULL,
    modelo  VARCHAR(50)     NOT NULL,
    id_conductor    BIGINT  NOT NULL,
    creado_en  TIMESTAMP   DEFAULT     CURRENT_TIMESTAMP,

    PRIMARY KEY (id_vehiculo),
    UNIQUE KEY uk_matricula (matricula),
    INDEX idx_vehiculo_conductor (id_conductor),
    FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;


-- Viaje
CREATE TABLE viaje (
    id_viaje    BIGINT  NOT NULL    AUTO_INCREMENT,
    id_rider    BIGINT  NOT NULL,
    origen_lat  DECIMAL(10,8)   NOT NULL,
    origen_lon  DECIMAL(11,8)   NOT NULL,
    destino_lat     DECIMAL(10,8)   NOT NULL,
    destino_lon     DECIMAL(11,8)   NOT NULL,
    distancia_km    DECIMAL(6,2)    NOT NULL,
    estado ENUM('solicitado','aceptado','en_curso','finalizado','cancelado') DEFAULT 'solicitado',
    precio DECIMAL(8,2) NOT NULL,
    id_conductor_aceptado BIGINT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_viaje),
    FOREIGN KEY (id_rider) REFERENCES rider(id_rider) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    INDEX idx_viaje_estado (estado)
) ENGINE=InnoDB;

-- Oferta
CREATE TABLE oferta (
    id_oferta   BIGINT  NOT NULL    AUTO_INCREMENT,
    id_viaje    BIGINT  NOT NULL,
    creado_en   TIMESTAMP   DEFAULT     CURRENT_TIMESTAMP,

    PRIMARY KEY (id_oferta),
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla intermedia del n:n Oferta <-> Conductor
-- El indice unico parcial (en schema de indices) garantiza
-- que solo un conductor pueda tener decision='aceptada' por oferta
CREATE TABLE oferta_conductor (
    id_oferta     BIGINT  NOT NULL,
    id_conductor  BIGINT  NOT NULL,
    decision ENUM('pendiente','aceptada','rechazada') NOT NULL DEFAULT 'pendiente',
    respondida_en TIMESTAMP NULL,

    PRIMARY KEY (id_oferta, id_conductor),
    FOREIGN KEY (id_oferta) REFERENCES oferta(id_oferta) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;


-- Company ↔ Vehiculo (N:N)
CREATE TABLE empresa_vehiculo (
    id_company  BIGINT  NOT NULL,
    id_vehiculo     BIGINT  NOT NULL,
    fecha_asignacion    DATE    NOT NULL,
    fecha_fin   DATE   DEFAULT NULL,

    PRIMARY KEY (id_company, id_vehiculo, fecha_asignacion),
    FOREIGN KEY (id_company) REFERENCES company(id_company) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo) 
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Trigger para actualizar el campo actualizado_en de viaje cuando se haga cualquier cambio
DELIMITER $$
CREATE TRIGGER trg_viaje_update 
BEFORE UPDATE ON viaje
FOR EACH ROW SET NEW.actualizado_en = CURRENT_TIMESTAMP
$$ DELIMITER ;
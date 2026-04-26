-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: rideHailing
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `rideHailing`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `rideHailing` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `rideHailing`;

--
-- Table structure for table `company`
--

DROP TABLE IF EXISTS `company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company` (
  `id_company` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) NOT NULL,
  `cif` varchar(20) NOT NULL,
  `pais` varchar(60) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_company`),
  UNIQUE KEY `uk_cif` (`cif`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company`
--

LOCK TABLES `company` WRITE;
/*!40000 ALTER TABLE `company` DISABLE KEYS */;
INSERT INTO `company` VALUES (1,'Cabify Spain SL','B12345678','EspaÃ±a','2026-04-26 06:50:34'),(2,'Bolt Iberia SL','B87654321','EspaÃ±a','2026-04-26 06:50:34'),(3,'Uber Portugal Lda','P11223344','Portugal','2026-04-26 06:50:34'),(4,'Free Now GmbH','D99887766','Alemania','2026-04-26 06:50:34'),(5,'Lyft Europe BV','N55443322','PaÃ­ses Bajos','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `company` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conductor`
--

DROP TABLE IF EXISTS `conductor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conductor` (
  `id_conductor` bigint NOT NULL AUTO_INCREMENT,
  `id_usuario` bigint NOT NULL,
  `id_company` bigint NOT NULL,
  `licencia` varchar(20) NOT NULL,
  `valoracion_media` decimal(3,2) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_conductor`),
  UNIQUE KEY `uk_licencia` (`licencia`),
  KEY `id_usuario` (`id_usuario`),
  KEY `id_company` (`id_company`),
  CONSTRAINT `conductor_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `conductor_ibfk_2` FOREIGN KEY (`id_company`) REFERENCES `company` (`id_company`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conductor`
--

LOCK TABLES `conductor` WRITE;
/*!40000 ALTER TABLE `conductor` DISABLE KEYS */;
INSERT INTO `conductor` VALUES (1,10,1,'LIC-001',5.00,'2026-04-26 06:50:34'),(2,11,1,'LIC-002',NULL,'2026-04-26 06:50:34'),(3,12,2,'LIC-003',NULL,'2026-04-26 06:50:34'),(4,13,3,'LIC-004',4.50,'2026-04-26 06:50:34'),(5,14,3,'LIC-005',NULL,'2026-04-26 06:50:34'),(6,15,4,'LIC-006',NULL,'2026-04-26 06:50:34'),(7,16,4,'LIC-007',NULL,'2026-04-26 06:50:34'),(8,17,5,'LIC-008',NULL,'2026-04-26 06:50:34'),(9,18,5,'LIC-009',NULL,'2026-04-26 06:50:34');
/*!40000 ALTER TABLE `conductor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empresa_vehiculo`
--

DROP TABLE IF EXISTS `empresa_vehiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empresa_vehiculo` (
  `id_company` bigint NOT NULL,
  `id_vehiculo` bigint NOT NULL,
  `fecha_asignacion` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  PRIMARY KEY (`id_company`,`id_vehiculo`,`fecha_asignacion`),
  KEY `id_vehiculo` (`id_vehiculo`),
  CONSTRAINT `empresa_vehiculo_ibfk_1` FOREIGN KEY (`id_company`) REFERENCES `company` (`id_company`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `empresa_vehiculo_ibfk_2` FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo` (`id_vehiculo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empresa_vehiculo`
--

LOCK TABLES `empresa_vehiculo` WRITE;
/*!40000 ALTER TABLE `empresa_vehiculo` DISABLE KEYS */;
INSERT INTO `empresa_vehiculo` VALUES (1,1,'2024-01-01',NULL),(1,2,'2024-01-01',NULL),(2,3,'2024-01-01',NULL),(3,4,'2024-01-01',NULL),(3,5,'2024-01-01',NULL),(4,6,'2024-01-01',NULL),(4,7,'2024-01-01',NULL),(5,8,'2024-01-01',NULL),(5,9,'2024-01-01',NULL);
/*!40000 ALTER TABLE `empresa_vehiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evento_viaje`
--

DROP TABLE IF EXISTS `evento_viaje`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evento_viaje` (
  `id_evento` bigint NOT NULL AUTO_INCREMENT,
  `id_viaje` bigint NOT NULL,
  `id_rider` bigint DEFAULT NULL,
  `id_conductor` bigint DEFAULT NULL,
  `tipo_evento` enum('solicitud','aceptacion','inicio','finalizacion','cancelacion') NOT NULL,
  `estado_anterior` enum('solicitado','aceptado','en_curso','finalizado','cancelado') DEFAULT NULL,
  `estado_nuevo` enum('solicitado','aceptado','en_curso','finalizado','cancelado') DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_evento`),
  KEY `idx_evento_viaje` (`id_viaje`),
  KEY `idx_evento_creado` (`creado_en`),
  KEY `idx_evento_rider` (`id_rider`),
  KEY `idx_evento_conductor` (`id_conductor`),
  CONSTRAINT `evento_viaje_ibfk_1` FOREIGN KEY (`id_viaje`) REFERENCES `viaje` (`id_viaje`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `evento_viaje_ibfk_2` FOREIGN KEY (`id_rider`) REFERENCES `rider` (`id_rider`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `evento_viaje_ibfk_3` FOREIGN KEY (`id_conductor`) REFERENCES `conductor` (`id_conductor`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evento_viaje`
--

LOCK TABLES `evento_viaje` WRITE;
/*!40000 ALTER TABLE `evento_viaje` DISABLE KEYS */;
INSERT INTO `evento_viaje` VALUES (1,1,NULL,1,'aceptacion','solicitado','aceptado','2026-04-26 06:50:34'),(2,1,NULL,1,'inicio','aceptado','en_curso','2026-04-26 06:50:34'),(3,1,NULL,1,'finalizacion','en_curso','finalizado','2026-04-26 06:50:34'),(4,2,NULL,4,'aceptacion','solicitado','aceptado','2026-04-26 06:50:34'),(5,2,NULL,4,'inicio','aceptado','en_curso','2026-04-26 06:50:34'),(6,2,NULL,4,'finalizacion','en_curso','finalizado','2026-04-26 06:50:34'),(7,3,NULL,4,'aceptacion','solicitado','aceptado','2026-04-26 06:50:34'),(8,3,NULL,4,'inicio','aceptado','en_curso','2026-04-26 06:50:34'),(9,3,NULL,4,'finalizacion','en_curso','finalizado','2026-04-26 06:50:34'),(10,4,NULL,1,'aceptacion','solicitado','aceptado','2026-04-26 06:50:34'),(11,4,NULL,1,'inicio','aceptado','en_curso','2026-04-26 06:50:34'),(12,4,NULL,1,'finalizacion','en_curso','finalizado','2026-04-26 06:50:34'),(13,5,NULL,NULL,'cancelacion','solicitado','cancelado','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `evento_viaje` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oferta`
--

DROP TABLE IF EXISTS `oferta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oferta` (
  `id_oferta` bigint NOT NULL AUTO_INCREMENT,
  `id_viaje` bigint NOT NULL,
  `estado` enum('pendiente','aceptada','rechazada','expirada') NOT NULL DEFAULT 'pendiente',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_oferta`),
  KEY `id_viaje` (`id_viaje`),
  CONSTRAINT `oferta_ibfk_1` FOREIGN KEY (`id_viaje`) REFERENCES `viaje` (`id_viaje`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oferta`
--

LOCK TABLES `oferta` WRITE;
/*!40000 ALTER TABLE `oferta` DISABLE KEYS */;
INSERT INTO `oferta` VALUES (1,1,'aceptada','2026-04-26 06:50:34'),(2,2,'aceptada','2026-04-26 06:50:34'),(3,3,'aceptada','2026-04-26 06:50:34'),(4,4,'aceptada','2026-04-26 06:50:34'),(5,5,'expirada','2026-04-26 06:50:34'),(6,6,'pendiente','2026-04-26 06:50:34'),(7,7,'pendiente','2026-04-26 06:50:34'),(8,8,'pendiente','2026-04-26 06:50:34'),(9,9,'pendiente','2026-04-26 06:50:34'),(10,10,'pendiente','2026-04-26 06:50:34'),(11,11,'pendiente','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `oferta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oferta_conductor`
--

DROP TABLE IF EXISTS `oferta_conductor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oferta_conductor` (
  `id_oferta` bigint NOT NULL,
  `id_conductor` bigint NOT NULL,
  `decision` enum('pendiente','aceptada','rechazada','expirada') NOT NULL DEFAULT 'pendiente',
  `respondida_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_oferta`,`id_conductor`),
  KEY `id_conductor` (`id_conductor`),
  CONSTRAINT `oferta_conductor_ibfk_1` FOREIGN KEY (`id_oferta`) REFERENCES `oferta` (`id_oferta`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `oferta_conductor_ibfk_2` FOREIGN KEY (`id_conductor`) REFERENCES `conductor` (`id_conductor`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oferta_conductor`
--

LOCK TABLES `oferta_conductor` WRITE;
/*!40000 ALTER TABLE `oferta_conductor` DISABLE KEYS */;
INSERT INTO `oferta_conductor` VALUES (1,1,'aceptada','2026-04-26 06:50:34'),(1,2,'rechazada','2026-04-26 06:50:34'),(1,4,'rechazada','2026-04-26 06:50:34'),(2,2,'rechazada','2026-04-26 06:50:34'),(2,4,'aceptada','2026-04-26 06:50:34'),(2,5,'rechazada','2026-04-26 06:50:34'),(3,4,'aceptada','2026-04-26 06:50:34'),(3,5,'rechazada','2026-04-26 06:50:34'),(3,6,'rechazada','2026-04-26 06:50:34'),(4,1,'aceptada','2026-04-26 06:50:34'),(4,2,'rechazada','2026-04-26 06:50:34'),(4,5,'rechazada','2026-04-26 06:50:34'),(5,1,'expirada','2026-04-26 06:50:34'),(5,2,'expirada','2026-04-26 06:50:34'),(5,4,'expirada','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `oferta_conductor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rider`
--

DROP TABLE IF EXISTS `rider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rider` (
  `id_rider` bigint NOT NULL AUTO_INCREMENT,
  `id_usuario` bigint NOT NULL,
  `metodo_pago` enum('tarjeta','efectivo','paypal') NOT NULL DEFAULT 'tarjeta',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_rider`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `rider_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rider`
--

LOCK TABLES `rider` WRITE;
/*!40000 ALTER TABLE `rider` DISABLE KEYS */;
INSERT INTO `rider` VALUES (1,1,'tarjeta','2026-04-26 06:50:34'),(2,2,'tarjeta','2026-04-26 06:50:34'),(3,3,'efectivo','2026-04-26 06:50:34'),(4,4,'tarjeta','2026-04-26 06:50:34'),(5,5,'paypal','2026-04-26 06:50:34'),(6,6,'tarjeta','2026-04-26 06:50:34'),(7,7,'efectivo','2026-04-26 06:50:34'),(8,8,'tarjeta','2026-04-26 06:50:34'),(9,9,'paypal','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `rider` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tarifa`
--

DROP TABLE IF EXISTS `tarifa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tarifa` (
  `id_tarifa` bigint NOT NULL AUTO_INCREMENT,
  `id_company` bigint NOT NULL,
  `euro_por_km` decimal(8,4) NOT NULL,
  `euro_por_minuto` decimal(8,4) NOT NULL,
  `precio_base` decimal(8,2) NOT NULL,
  `vigente_desde` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tarifa`),
  KEY `idx_tarifa_company` (`id_company`),
  CONSTRAINT `tarifa_ibfk_1` FOREIGN KEY (`id_company`) REFERENCES `company` (`id_company`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tarifa`
--

LOCK TABLES `tarifa` WRITE;
/*!40000 ALTER TABLE `tarifa` DISABLE KEYS */;
INSERT INTO `tarifa` VALUES (1,1,1.2000,0.2000,2.50,'2026-04-26 06:50:34'),(2,2,1.1000,0.2500,3.00,'2026-04-26 06:50:34'),(3,3,1.3000,0.1500,2.00,'2026-04-26 06:50:34'),(4,4,1.2500,0.1800,2.80,'2026-04-26 06:50:34'),(5,5,1.1500,0.2200,2.60,'2026-04-26 06:50:34');
/*!40000 ALTER TABLE `tarifa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `email` varchar(120) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `estado` enum('activo','inactivo','bloqueado') NOT NULL DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_telefono` (`telefono`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Juan PÃ©rez','juan@email.com','600000001','hash1',NULL,'activo','2026-04-26 06:50:34'),(2,'MarÃ­a GarcÃ­a','maria@email.com','600000002','hash2',NULL,'activo','2026-04-26 06:50:34'),(3,'Carlos RodrÃ­guez','carlos@email.com','600000003','hash3',NULL,'activo','2026-04-26 06:50:34'),(4,'SofÃ­a FernÃ¡ndez','sofia@email.com','600000004','hash4',NULL,'activo','2026-04-26 06:50:34'),(5,'Laura MartÃ­nez','laura@email.com','600000005','hash5',NULL,'activo','2026-04-26 06:50:34'),(6,'Antonio Ruiz','antonio@email.com','600000006','hash6',NULL,'activo','2026-04-26 06:50:34'),(7,'Marta SÃ¡nchez','marta@email.com','600000007','hash7',NULL,'activo','2026-04-26 06:50:34'),(8,'David GÃ³mez','david@email.com','600000008','hash8',NULL,'activo','2026-04-26 06:50:34'),(9,'Pedro LÃ³pez','pedro@email.com','600000009','hash9',NULL,'activo','2026-04-26 06:50:34'),(10,'Antonio Ruiz C','antonioRuiz@email.com','600000010','hash10',NULL,'activo','2026-04-26 06:50:34'),(11,'Laura MartÃ­nez C','lauraMartinez@email.com','600000011','hash11',NULL,'activo','2026-04-26 06:50:34'),(12,'SofÃ­a FernÃ¡ndez C','sofiaFernandez@email.com','600000012','hash12',NULL,'activo','2026-04-26 06:50:34'),(13,'David GÃ³mez C','davidGomez@email.com','600000013','hash13',NULL,'activo','2026-04-26 06:50:34'),(14,'Marta SÃ¡nchez C','martaSanchez@email.com','600000014','hash14',NULL,'activo','2026-04-26 06:50:34'),(15,'Juan PÃ©rez C','juanPerez@email.com','600000015','hash15',NULL,'activo','2026-04-26 06:50:34'),(16,'MarÃ­a GarcÃ­a C','mariaGarcia@email.com','600000016','hash16',NULL,'activo','2026-04-26 06:50:34'),(17,'Pedro LÃ³pez C','pedroLopez@email.com','600000017','hash17',NULL,'activo','2026-04-26 06:50:34'),(18,'Carlos RodrÃ­guez C','carlosRodriguez@email.com','600000018','hash18',NULL,'activo','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_rider_publico`
--

DROP TABLE IF EXISTS `v_rider_publico`;
/*!50001 DROP VIEW IF EXISTS `v_rider_publico`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_rider_publico` AS SELECT 
 1 AS `id_rider`,
 1 AS `nombre`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `valoracion`
--

DROP TABLE IF EXISTS `valoracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `valoracion` (
  `id_valoracion` bigint NOT NULL AUTO_INCREMENT,
  `id_viaje` bigint NOT NULL,
  `id_rider` bigint NOT NULL,
  `id_conductor` bigint NOT NULL,
  `puntuacion` int NOT NULL,
  `comentario` varchar(300) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_valoracion`),
  UNIQUE KEY `uk_valoracion_viaje` (`id_viaje`),
  KEY `idx_valoracion_conductor` (`id_conductor`),
  KEY `idx_valoracion_rider` (`id_rider`),
  CONSTRAINT `valoracion_ibfk_1` FOREIGN KEY (`id_viaje`) REFERENCES `viaje` (`id_viaje`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `valoracion_ibfk_2` FOREIGN KEY (`id_rider`) REFERENCES `rider` (`id_rider`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `valoracion_ibfk_3` FOREIGN KEY (`id_conductor`) REFERENCES `conductor` (`id_conductor`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `verificacion_puntuacion` CHECK ((`puntuacion` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `valoracion`
--

LOCK TABLES `valoracion` WRITE;
/*!40000 ALTER TABLE `valoracion` DISABLE KEYS */;
INSERT INTO `valoracion` VALUES (1,1,1,1,5,'Excelente servicio, muy puntual y amable.','2026-04-26 06:50:34'),(2,2,2,4,4,'Buen viaje, aunque el conductor podrÃ­a ser mÃ¡s amigable.','2026-04-26 06:50:34'),(3,3,3,4,5,'Viaje perfecto, el conductor fue muy profesional.','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `valoracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehiculo`
--

DROP TABLE IF EXISTS `vehiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehiculo` (
  `id_vehiculo` bigint NOT NULL AUTO_INCREMENT,
  `matricula` varchar(16) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `anio` year NOT NULL,
  `id_conductor` bigint NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_vehiculo`),
  UNIQUE KEY `uk_matricula` (`matricula`),
  KEY `idx_vehiculo_conductor` (`id_conductor`),
  CONSTRAINT `vehiculo_ibfk_1` FOREIGN KEY (`id_conductor`) REFERENCES `conductor` (`id_conductor`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehiculo`
--

LOCK TABLES `vehiculo` WRITE;
/*!40000 ALTER TABLE `vehiculo` DISABLE KEYS */;
INSERT INTO `vehiculo` VALUES (1,'ABC1234','Toyota','Prius',2020,1,'2026-04-26 06:50:34'),(2,'XYZ5678','Tesla','Model 3',2021,2,'2026-04-26 06:50:34'),(3,'DEF9012','Seat','Leon',2019,3,'2026-04-26 06:50:34'),(4,'GHI3456','Renault','Clio',2020,4,'2026-04-26 06:50:34'),(5,'JKL7890','Ford','Focus',2018,5,'2026-04-26 06:50:34'),(6,'MNO1122','Volkswagen','Golf',2022,6,'2026-04-26 06:50:34'),(7,'PQR3344','BMW','Serie 3',2023,7,'2026-04-26 06:50:34'),(8,'STU5566','Honda','Civic',2020,8,'2026-04-26 06:50:34'),(9,'VWX7788','Hyundai','Ioniq',2022,9,'2026-04-26 06:50:34');
/*!40000 ALTER TABLE `vehiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `viaje`
--

DROP TABLE IF EXISTS `viaje`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viaje` (
  `id_viaje` bigint NOT NULL AUTO_INCREMENT,
  `id_rider` bigint NOT NULL,
  `id_conductor_aceptado` bigint DEFAULT NULL,
  `id_tarifa` bigint DEFAULT NULL,
  `origen_lat` decimal(10,8) NOT NULL,
  `origen_lon` decimal(11,8) NOT NULL,
  `destino_lat` decimal(10,8) NOT NULL,
  `destino_lon` decimal(11,8) NOT NULL,
  `distancia_km` decimal(6,2) DEFAULT NULL,
  `duracion_minutos` decimal(6,2) DEFAULT NULL,
  `estado` enum('solicitado','aceptado','en_curso','finalizado','cancelado') DEFAULT 'solicitado',
  `precio_total` decimal(8,2) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_viaje`),
  KEY `idx_viaje_estado` (`estado`),
  KEY `idx_viaje_rider` (`id_rider`),
  KEY `idx_viaje_conductor_aceptado` (`id_conductor_aceptado`),
  KEY `idx_viaje_creado_en` (`creado_en`),
  KEY `id_tarifa` (`id_tarifa`),
  CONSTRAINT `viaje_ibfk_1` FOREIGN KEY (`id_conductor_aceptado`) REFERENCES `conductor` (`id_conductor`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `viaje_ibfk_2` FOREIGN KEY (`id_rider`) REFERENCES `rider` (`id_rider`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `viaje_ibfk_3` FOREIGN KEY (`id_tarifa`) REFERENCES `tarifa` (`id_tarifa`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viaje`
--

LOCK TABLES `viaje` WRITE;
/*!40000 ALTER TABLE `viaje` DISABLE KEYS */;
INSERT INTO `viaje` VALUES (1,1,1,1,40.41677500,-3.70379000,40.41805600,-3.70444400,2.50,15.00,'finalizado',5.00,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(2,2,4,2,40.41677500,-3.70379000,40.41900000,-3.70500000,3.00,20.00,'finalizado',6.50,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(3,3,4,3,40.41677500,-3.70379000,40.42000000,-3.70600000,4.00,25.00,'finalizado',8.00,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(4,4,1,4,40.41677500,-3.70379000,40.42100000,-3.70700000,5.00,30.00,'finalizado',10.00,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(5,5,NULL,5,40.41677500,-3.70379000,40.42200000,-3.70800000,6.00,35.00,'cancelado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(6,6,NULL,1,40.41677500,-3.70379000,40.42300000,-3.70900000,NULL,NULL,'solicitado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(7,7,NULL,2,40.41677500,-3.70379000,40.42400000,-3.71000000,NULL,NULL,'solicitado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(8,8,NULL,3,40.41677500,-3.70379000,40.42500000,-3.71100000,NULL,NULL,'solicitado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(9,9,NULL,4,40.41677500,-3.70379000,40.42600000,-3.71200000,NULL,NULL,'solicitado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(10,2,1,2,40.41800000,-3.70500000,40.42200000,-3.70900000,NULL,NULL,'aceptado',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34'),(11,3,4,3,40.41900000,-3.70600000,40.42300000,-3.71000000,NULL,NULL,'en_curso',NULL,'2026-04-26 06:50:34','2026-04-26 06:50:34');
/*!40000 ALTER TABLE `viaje` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'rideHailing'
--

--
-- Dumping routines for database 'rideHailing'
--

--
-- Current Database: `rideHailing`
--

USE `rideHailing`;

--
-- Final view structure for view `v_rider_publico`
--

/*!50001 DROP VIEW IF EXISTS `v_rider_publico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_rider_publico` AS select `r`.`id_rider` AS `id_rider`,`u`.`nombre` AS `nombre` from (`rider` `r` join `usuario` `u` on((`u`.`id_usuario` = `r`.`id_usuario`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-26  6:58:24

-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: libreria_ecommerce
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.3

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
-- Table structure for table `calificaciones`
--

DROP TABLE IF EXISTS `calificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calificaciones` (
  `id_calificacion` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `id_usuario_calificador` int NOT NULL,
  `id_usuario_calificado` int NOT NULL,
  `puntaje` decimal(5,2) NOT NULL,
  `comentario` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_calificacion` enum('Comprador','Vendedor') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_calificacion`),
  KEY `fk_calif_venta` (`id_venta`),
  KEY `fk_calif_calificador` (`id_usuario_calificador`),
  KEY `fk_calif_calificado` (`id_usuario_calificado`),
  CONSTRAINT `fk_calif_calificado` FOREIGN KEY (`id_usuario_calificado`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_calif_calificador` FOREIGN KEY (`id_usuario_calificador`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_calif_venta` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`),
  CONSTRAINT `chk_puntaje` CHECK ((`puntaje` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
INSERT INTO `calificaciones` VALUES (1,1,6,1,95.00,'Excelente vendedor, todo perfecto.','Vendedor','2025-04-15 09:00:00'),(2,1,1,6,100.00,'Comprador impecable.','Comprador','2025-04-15 09:10:00'),(3,2,4,2,90.00,'Buena comunicaciÃ³n.','Vendedor','2025-04-21 10:00:00'),(4,2,2,4,90.00,'Pago rÃ¡pido.','Comprador','2025-04-21 10:15:00'),(5,3,7,3,85.00,'Todo bien, un poco lento el envÃ­o.','Vendedor','2025-04-10 09:00:00'),(6,3,3,7,95.00,'Comprador correcto.','Comprador','2025-04-10 09:20:00'),(7,4,8,4,100.00,'Perfecto, tal cual la descripciÃ³n.','Vendedor','2025-04-04 08:00:00'),(8,4,4,8,100.00,'Todo excelente.','Comprador','2025-04-04 08:15:00');
/*!40000 ALTER TABLE `calificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'FicciÃ³n','Novelas y relatos de ficciÃ³n'),(2,'Ciencia FicciÃ³n','Libros de ciencia ficciÃ³n y distopÃ­as'),(3,'FantasÃ­a','Libros de fantasÃ­a y mundos imaginarios'),(4,'Historia','Libros de historia y ensayos histÃ³ricos'),(5,'ProgramaciÃ³n','Libros tÃ©cnicos de programaciÃ³n e informÃ¡tica'),(6,'Autoayuda','Libros de desarrollo personal'),(7,'Infantil','Libros para chicos');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estadisticas_diarias`
--

DROP TABLE IF EXISTS `estadisticas_diarias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estadisticas_diarias` (
  `id_estadistica` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `cant_ventas` int NOT NULL DEFAULT '0',
  `facturacion_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `cant_usuarios_nuevos` int NOT NULL DEFAULT '0',
  `cant_productos_nuevos` int NOT NULL DEFAULT '0',
  `fecha_generacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_estadistica`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estadisticas_diarias`
--

LOCK TABLES `estadisticas_diarias` WRITE;
/*!40000 ALTER TABLE `estadisticas_diarias` DISABLE KEYS */;
/*!40000 ALTER TABLE `estadisticas_diarias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medios_envio`
--

DROP TABLE IF EXISTS `medios_envio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medios_envio` (
  `id_medio_envio` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_medio_envio`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medios_envio`
--

LOCK TABLES `medios_envio` WRITE;
/*!40000 ALTER TABLE `medios_envio` DISABLE KEYS */;
INSERT INTO `medios_envio` VALUES (1,'OCA'),(2,'Correo Argentino');
/*!40000 ALTER TABLE `medios_envio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medios_pago`
--

DROP TABLE IF EXISTS `medios_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medios_pago` (
  `id_medio_pago` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_medio_pago`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medios_pago`
--

LOCK TABLES `medios_pago` WRITE;
/*!40000 ALTER TABLE `medios_pago` DISABLE KEYS */;
INSERT INTO `medios_pago` VALUES (1,'Tarjeta de crÃ©dito'),(2,'Tarjeta de dÃ©bito'),(3,'Pago FÃ¡cil'),(4,'Rapipago');
/*!40000 ALTER TABLE `medios_pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificaciones` (
  `id_notificacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `mensaje` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `leida` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_notificacion`),
  KEY `fk_notif_usuario` (`id_usuario`),
  CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
INSERT INTO `notificaciones` VALUES (1,1,'La publicación sobre 1984 tiene 1 sin responder','2026-08-13 10:00:00',0),(2,3,'La publicación sobre Clean Code tiene 3 sin responder','2026-08-13 10:00:00',0),(3,5,'La publicación sobre Dune tiene 1 sin responder','2026-08-13 10:00:00',0),(4,1,'La publicación sobre 1984 tiene 1 sin responder','2026-08-14 10:00:00',0),(5,3,'La publicación sobre Clean Code tiene 3 sin responder','2026-08-14 10:00:00',0),(6,5,'La publicación sobre Dune tiene 1 sin responder','2026-08-14 10:00:00',0);
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preguntas`
--

DROP TABLE IF EXISTS `preguntas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `preguntas` (
  `id_pregunta` int NOT NULL AUTO_INCREMENT,
  `id_publicacion` int NOT NULL,
  `id_usuario` int NOT NULL,
  `contenido` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pregunta`),
  KEY `fk_preg_publicacion` (`id_publicacion`),
  KEY `fk_preg_usuario` (`id_usuario`),
  CONSTRAINT `fk_preg_publicacion` FOREIGN KEY (`id_publicacion`) REFERENCES `publicaciones` (`id_publicacion`) ON DELETE CASCADE,
  CONSTRAINT `fk_preg_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preguntas`
--

LOCK TABLES `preguntas` WRITE;
/*!40000 ALTER TABLE `preguntas` DISABLE KEYS */;
INSERT INTO `preguntas` VALUES (1,2,3,'Â¿El libro es ediciÃ³n tapa dura o blanda?','2025-04-12 12:00:00'),(2,2,4,'Â¿Tiene algÃºn subrayado o marca?','2025-04-12 15:00:00'),(3,6,4,'Â¿Es la primera o segunda ediciÃ³n?','2025-04-13 10:00:00'),(4,6,5,'Â¿Incluye los ejemplos en Java?','2025-04-13 11:00:00'),(5,6,6,'Â¿Tiene anotaciones a mano?','2025-04-13 12:00:00'),(6,9,6,'Â¿La tapa estÃ¡ en buen estado?','2025-04-15 10:00:00'),(7,10,7,'Â¿Hace envÃ­os fuera de CABA?','2025-04-16 10:00:00');
/*!40000 ALTER TABLE `preguntas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `autor` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `editorial` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `anio_publicacion` int DEFAULT NULL,
  `idioma` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'EspaÃ±ol',
  `id_usuario` int NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`),
  KEY `fk_producto_usuario` (`id_usuario`),
  KEY `idx_producto_nombre` (`nombre`),
  KEY `idx_producto_autor` (`autor`),
  CONSTRAINT `fk_producto_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'Cien aÃ±os de soledad','Novela emblemÃ¡tica del realismo mÃ¡gico latinoamericano.','Gabriel GarcÃ­a MÃ¡rquez','978-0307474728','Sudamericana',1967,'EspaÃ±ol',1,'2025-04-01 10:00:00'),(2,'1984','DistopÃ­a sobre un rÃ©gimen totalitario y la vigilancia masiva.','George Orwell','978-0451524935','Debolsillo',1949,'EspaÃ±ol',1,'2025-04-02 10:00:00'),(3,'FundaciÃ³n','Primer libro de la saga de ciencia ficciÃ³n sobre el Imperio GalÃ¡ctico.','Isaac Asimov','978-0553293357','Debolsillo',1951,'EspaÃ±ol',2,'2025-04-03 11:00:00'),(4,'El nombre del viento','Primer libro de la saga CrÃ³nica del Asesino de Reyes.','Patrick Rothfuss','978-8401352836','Plaza & JanÃ©s',2007,'EspaÃ±ol',2,'2025-04-04 11:30:00'),(5,'Sapiens: De animales a dioses','Breve historia de la humanidad.','Yuval Noah Harari','978-9500397174','Debate',2011,'EspaÃ±ol',3,'2025-04-05 09:00:00'),(6,'Clean Code','GuÃ­a de buenas prÃ¡cticas para escribir cÃ³digo limpio y mantenible.','Robert C. Martin','978-0132350884','Prentice Hall',2008,'InglÃ©s',3,'2025-04-06 15:00:00'),(7,'El poder del ahora','Libro de autoayuda sobre el presente y la conciencia.','Eckhart Tolle','978-8497771120','Gaia Ediciones',1997,'EspaÃ±ol',4,'2025-04-07 12:00:00'),(8,'Harry Potter y la piedra filosofal','Primer libro de la saga de Harry Potter.','J. K. Rowling','978-8478884452','Salamandra',1997,'EspaÃ±ol',4,'2025-04-08 13:00:00'),(9,'Dune','Novela de ciencia ficciÃ³n ambientada en el planeta desÃ©rtico Arrakis.','Frank Herbert','978-0441172719','Debolsillo',1965,'EspaÃ±ol',5,'2025-04-09 10:30:00'),(10,'El hobbit','Aventura previa a El SeÃ±or de los Anillos.','J. R. R. Tolkien','978-8445073809','Minotauro',1937,'EspaÃ±ol',5,'2025-04-10 14:00:00');
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publicacion_medio_envio`
--

DROP TABLE IF EXISTS `publicacion_medio_envio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publicacion_medio_envio` (
  `id_publicacion` int NOT NULL,
  `id_medio_envio` int NOT NULL,
  PRIMARY KEY (`id_publicacion`,`id_medio_envio`),
  KEY `fk_pme_medio` (`id_medio_envio`),
  CONSTRAINT `fk_pme_medio` FOREIGN KEY (`id_medio_envio`) REFERENCES `medios_envio` (`id_medio_envio`),
  CONSTRAINT `fk_pme_publicacion` FOREIGN KEY (`id_publicacion`) REFERENCES `publicaciones` (`id_publicacion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publicacion_medio_envio`
--

LOCK TABLES `publicacion_medio_envio` WRITE;
/*!40000 ALTER TABLE `publicacion_medio_envio` DISABLE KEYS */;
INSERT INTO `publicacion_medio_envio` VALUES (1,1),(2,1),(5,1),(8,1),(10,1),(1,2),(5,2),(10,2);
/*!40000 ALTER TABLE `publicacion_medio_envio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publicacion_medio_pago`
--

DROP TABLE IF EXISTS `publicacion_medio_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publicacion_medio_pago` (
  `id_publicacion` int NOT NULL,
  `id_medio_pago` int NOT NULL,
  PRIMARY KEY (`id_publicacion`,`id_medio_pago`),
  KEY `fk_pmp_medio` (`id_medio_pago`),
  CONSTRAINT `fk_pmp_medio` FOREIGN KEY (`id_medio_pago`) REFERENCES `medios_pago` (`id_medio_pago`),
  CONSTRAINT `fk_pmp_publicacion` FOREIGN KEY (`id_publicacion`) REFERENCES `publicaciones` (`id_publicacion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publicacion_medio_pago`
--

LOCK TABLES `publicacion_medio_pago` WRITE;
/*!40000 ALTER TABLE `publicacion_medio_pago` DISABLE KEYS */;
INSERT INTO `publicacion_medio_pago` VALUES (1,1),(2,1),(5,1),(8,1),(1,2),(8,2),(10,2),(2,3),(10,3);
/*!40000 ALTER TABLE `publicacion_medio_pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publicaciones`
--

DROP TABLE IF EXISTS `publicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `publicaciones` (
  `id_publicacion` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `id_categoria` int NOT NULL,
  `id_usuario_vendedor` int NOT NULL,
  `tipo_venta` enum('Directa','Subasta') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_tipo_publicacion` int NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `estado` enum('Activa','Pausada','Finalizada','Observada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Activa',
  `fecha_publicacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_finalizacion` datetime DEFAULT NULL,
  PRIMARY KEY (`id_publicacion`),
  KEY `fk_pub_producto` (`id_producto`),
  KEY `fk_pub_categoria` (`id_categoria`),
  KEY `fk_pub_vendedor` (`id_usuario_vendedor`),
  KEY `fk_pub_tipo` (`id_tipo_publicacion`),
  KEY `idx_publicacion_estado` (`estado`),
  KEY `idx_publicacion_vendedor_estado` (`id_usuario_vendedor`,`estado`),
  CONSTRAINT `fk_pub_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  CONSTRAINT `fk_pub_producto` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_pub_tipo` FOREIGN KEY (`id_tipo_publicacion`) REFERENCES `tipos_publicacion` (`id_tipo_publicacion`),
  CONSTRAINT `fk_pub_vendedor` FOREIGN KEY (`id_usuario_vendedor`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publicaciones`
--

LOCK TABLES `publicaciones` WRITE;
/*!40000 ALTER TABLE `publicaciones` DISABLE KEYS */;
INSERT INTO `publicaciones` VALUES (1,1,1,1,'Directa',3,15000.00,'Finalizada','2025-04-11 09:00:00','2025-04-14 18:00:00'),(2,2,2,1,'Directa',2,12000.00,'Activa','2025-04-12 09:30:00',NULL),(3,3,2,2,'Subasta',3,8000.00,'Finalizada','2025-04-05 10:00:00','2025-04-20 20:00:00'),(5,5,4,3,'Directa',4,14000.00,'Finalizada','2025-04-07 08:45:00','2025-04-09 12:00:00'),(6,6,5,3,'Subasta',2,20000.00,'Activa','2025-04-13 09:00:00',NULL),(7,7,6,4,'Directa',1,9000.00,'Observada','2025-04-14 11:00:00',NULL),(8,8,7,4,'Directa',3,22000.00,'Finalizada','2025-04-01 09:00:00','2025-04-03 10:00:00'),(9,9,2,5,'Subasta',4,25000.00,'Activa','2025-04-15 09:00:00',NULL),(10,10,3,5,'Directa',2,13000.00,'Activa','2025-04-16 09:00:00',NULL);
/*!40000 ALTER TABLE `publicaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pujas`
--

DROP TABLE IF EXISTS `pujas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pujas` (
  `id_puja` int NOT NULL AUTO_INCREMENT,
  `id_publicacion` int NOT NULL,
  `id_usuario` int NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_puja`),
  KEY `fk_puja_publicacion` (`id_publicacion`),
  KEY `fk_puja_usuario` (`id_usuario`),
  CONSTRAINT `fk_puja_publicacion` FOREIGN KEY (`id_publicacion`) REFERENCES `publicaciones` (`id_publicacion`) ON DELETE CASCADE,
  CONSTRAINT `fk_puja_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pujas`
--

LOCK TABLES `pujas` WRITE;
/*!40000 ALTER TABLE `pujas` DISABLE KEYS */;
INSERT INTO `pujas` VALUES (1,3,3,8500.00,'2025-04-06 10:00:00'),(2,3,4,9500.00,'2025-04-08 11:00:00'),(3,3,6,10200.00,'2025-04-12 09:00:00'),(4,3,4,11000.00,'2025-04-18 16:00:00'),(5,6,4,20500.00,'2025-04-13 13:00:00'),(6,6,7,21000.00,'2025-04-14 09:00:00');
/*!40000 ALTER TABLE `pujas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `respuestas`
--

DROP TABLE IF EXISTS `respuestas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `respuestas` (
  `id_respuesta` int NOT NULL AUTO_INCREMENT,
  `id_pregunta` int NOT NULL,
  `contenido` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_respuesta`),
  KEY `fk_resp_pregunta` (`id_pregunta`),
  CONSTRAINT `fk_resp_pregunta` FOREIGN KEY (`id_pregunta`) REFERENCES `preguntas` (`id_pregunta`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `respuestas`
--

LOCK TABLES `respuestas` WRITE;
/*!40000 ALTER TABLE `respuestas` DISABLE KEYS */;
INSERT INTO `respuestas` VALUES (1,1,'Es tapa blanda, ediciÃ³n Debolsillo.','2025-04-12 13:00:00'),(2,7,'SÃ­, hago envÃ­os a todo el paÃ­s por OCA o Correo Argentino.','2025-04-16 11:00:00');
/*!40000 ALTER TABLE `respuestas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_publicacion`
--

DROP TABLE IF EXISTS `tipos_publicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipos_publicacion` (
  `id_tipo_publicacion` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `prioridad` int NOT NULL,
  PRIMARY KEY (`id_tipo_publicacion`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_publicacion`
--

LOCK TABLES `tipos_publicacion` WRITE;
/*!40000 ALTER TABLE `tipos_publicacion` DISABLE KEYS */;
INSERT INTO `tipos_publicacion` VALUES (1,'Bronce',1),(2,'Plata',2),(3,'Oro',3),(4,'Platino',4);
/*!40000 ALTER TABLE `tipos_publicacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nivel` enum('Normal','Platinum','Gold') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Normal',
  `reputacion` decimal(5,2) NOT NULL DEFAULT '100.00',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uidx_usuario_email` (`email`),
  CONSTRAINT `chk_reputacion` CHECK ((`reputacion` between 0 and 100))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Juan','Perez','juan.perez@mail.com','hash1','2025-01-10 10:00:00','Normal',100.00,1),(2,'Maria','Gomez','maria.gomez@mail.com','hash2','2025-01-15 11:30:00','Normal',100.00,1),(3,'Carlos','Fernandez','carlos.fernandez@mail.com','hash3','2025-02-01 09:15:00','Normal',100.00,1),(4,'Sofia','Martinez','sofia.martinez@mail.com','hash4','2025-02-10 14:20:00','Normal',100.00,1),(5,'Diego','Lopez','diego.lopez@mail.com','hash5','2025-02-20 16:45:00','Normal',100.00,1),(6,'Lucia','Rodriguez','lucia.rodriguez@mail.com','hash6','2025-03-01 08:00:00','Normal',100.00,1),(7,'Martin','Gonzalez','martin.gonzalez@mail.com','hash7','2025-03-05 12:00:00','Normal',100.00,1),(8,'Julian','Alvarez','julian.alvarez@mail.com','hash8','2025-03-10 17:30:00','Normal',100.00,1),(9,'Camila','Torres','camila.torres@mail.com','hash9','2025-03-15 10:10:00','Normal',100.00,1),(10,'Nicolas','Diaz','nicolas.diaz@mail.com','hash10','2025-04-01 09:00:00','Normal',100.00,1);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ventas` (
  `id_venta` int NOT NULL AUTO_INCREMENT,
  `id_publicacion` int NOT NULL,
  `id_comprador` int NOT NULL,
  `id_medio_pago` int DEFAULT NULL,
  `id_medio_envio` int DEFAULT NULL,
  `monto_final` decimal(10,2) NOT NULL,
  `fecha_venta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('Concretada','Cancelada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Concretada',
  PRIMARY KEY (`id_venta`),
  KEY `fk_venta_publicacion` (`id_publicacion`),
  KEY `fk_venta_comprador` (`id_comprador`),
  KEY `fk_venta_mediopago` (`id_medio_pago`),
  KEY `fk_venta_medioenvio` (`id_medio_envio`),
  CONSTRAINT `fk_venta_comprador` FOREIGN KEY (`id_comprador`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_venta_medioenvio` FOREIGN KEY (`id_medio_envio`) REFERENCES `medios_envio` (`id_medio_envio`),
  CONSTRAINT `fk_venta_mediopago` FOREIGN KEY (`id_medio_pago`) REFERENCES `medios_pago` (`id_medio_pago`),
  CONSTRAINT `fk_venta_publicacion` FOREIGN KEY (`id_publicacion`) REFERENCES `publicaciones` (`id_publicacion`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
INSERT INTO `ventas` VALUES (1,1,6,1,1,15000.00,'2025-04-14 18:00:00','Concretada'),(2,3,4,2,1,11000.00,'2025-04-20 20:00:00','Concretada'),(3,5,7,1,2,14000.00,'2025-04-09 12:00:00','Concretada'),(4,8,8,1,1,22000.00,'2025-04-03 10:00:00','Concretada');
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vista_mejor_reputacion_por_categoria`
--

DROP TABLE IF EXISTS `vista_mejor_reputacion_por_categoria`;
/*!50001 DROP VIEW IF EXISTS `vista_mejor_reputacion_por_categoria`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_mejor_reputacion_por_categoria` AS SELECT 
 1 AS `nombre_categoria`,
 1 AS `nombre_vendedor`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_preguntas_sin_responder`
--

DROP TABLE IF EXISTS `vista_preguntas_sin_responder`;
/*!50001 DROP VIEW IF EXISTS `vista_preguntas_sin_responder`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_preguntas_sin_responder` AS SELECT 
 1 AS `id_pregunta`,
 1 AS `descripcion`,
 1 AS `id_publicacion`,
 1 AS `nombre_producto`,
 1 AS `nombre_usuario_pregunta`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_publicaciones_tendencia`
--

DROP TABLE IF EXISTS `vista_publicaciones_tendencia`;
/*!50001 DROP VIEW IF EXISTS `vista_publicaciones_tendencia`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_publicaciones_tendencia` AS SELECT 
 1 AS `id_publicacion`,
 1 AS `nombre_producto`,
 1 AS `estado`,
 1 AS `cantidad_preguntas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vista_top10_categorias_semana`
--

DROP TABLE IF EXISTS `vista_top10_categorias_semana`;
/*!50001 DROP VIEW IF EXISTS `vista_top10_categorias_semana`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vista_top10_categorias_semana` AS SELECT 
 1 AS `id_categoria`,
 1 AS `nombre_categoria`,
 1 AS `cantidad_publicaciones`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vista_mejor_reputacion_por_categoria`
--

/*!50001 DROP VIEW IF EXISTS `vista_mejor_reputacion_por_categoria`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`alumno27.tana.felipe`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_mejor_reputacion_por_categoria` AS select `c`.`nombre` AS `nombre_categoria`,(select concat(`u2`.`nombre`,' ',`u2`.`apellido`) from (`usuarios` `u2` join `publicaciones` `p2` on((`p2`.`id_usuario_vendedor` = `u2`.`id_usuario`))) where (`p2`.`id_categoria` = `c`.`id_categoria`) order by `u2`.`reputacion` desc,`u2`.`id_usuario` limit 1) AS `nombre_vendedor` from `categorias` `c` where exists(select 1 from `publicaciones` `p3` where (`p3`.`id_categoria` = `c`.`id_categoria`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_preguntas_sin_responder`
--

/*!50001 DROP VIEW IF EXISTS `vista_preguntas_sin_responder`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`alumno27.tana.felipe`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_preguntas_sin_responder` AS select `pr`.`id_pregunta` AS `id_pregunta`,`pr`.`contenido` AS `descripcion`,`pr`.`id_publicacion` AS `id_publicacion`,`prod`.`nombre` AS `nombre_producto`,concat(`u`.`nombre`,' ',`u`.`apellido`) AS `nombre_usuario_pregunta` from (((`preguntas` `pr` join `publicaciones` `pub` on((`pub`.`id_publicacion` = `pr`.`id_publicacion`))) join `productos` `prod` on((`prod`.`id_producto` = `pub`.`id_producto`))) join `usuarios` `u` on((`u`.`id_usuario` = `pr`.`id_usuario`))) where ((`pub`.`estado` = 'Activa') and exists(select 1 from `respuestas` `r` where (`r`.`id_pregunta` = `pr`.`id_pregunta`)) is false) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_publicaciones_tendencia`
--

/*!50001 DROP VIEW IF EXISTS `vista_publicaciones_tendencia`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`alumno27.tana.felipe`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_publicaciones_tendencia` AS select `p`.`id_publicacion` AS `id_publicacion`,`prod`.`nombre` AS `nombre_producto`,`p`.`estado` AS `estado`,count(`pr`.`id_pregunta`) AS `cantidad_preguntas` from ((`publicaciones` `p` join `productos` `prod` on((`prod`.`id_producto` = `p`.`id_producto`))) join `preguntas` `pr` on((`pr`.`id_publicacion` = `p`.`id_publicacion`))) where (`p`.`estado` = 'Activa') group by `p`.`id_publicacion`,`prod`.`nombre`,`p`.`estado` having (`cantidad_preguntas` > 0) order by `cantidad_preguntas` desc limit 10 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vista_top10_categorias_semana`
--

/*!50001 DROP VIEW IF EXISTS `vista_top10_categorias_semana`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`alumno27.tana.felipe`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vista_top10_categorias_semana` AS select `c`.`id_categoria` AS `id_categoria`,`c`.`nombre` AS `nombre_categoria`,count(0) AS `cantidad_publicaciones` from (`publicaciones` `p` join `categorias` `c` on((`c`.`id_categoria` = `p`.`id_categoria`))) where (yearweek(`p`.`fecha_publicacion`,1) = yearweek(curdate(),1)) group by `c`.`id_categoria`,`c`.`nombre` order by `cantidad_publicaciones` desc limit 10 */;
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

-- Dump completed on 2026-08-20  9:51:31

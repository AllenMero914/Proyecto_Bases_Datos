DROP DATABASE IF EXISTS calzado_db;

CREATE DATABASE calzado_db;
USE calzado_db;

-- =========================================================
-- CREACIÓN DE TABLAS
-- =========================================================

-- 1. CATEGORIAS
CREATE TABLE categorias(
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

-- 2. PROVEEDORES
CREATE TABLE proveedores(
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proveedor VARCHAR(100) NOT NULL,
    pais VARCHAR(100),
    tipo_proveedor VARCHAR(50) NOT NULL,
    telefono VARCHAR(15),
    CHECK (tipo_proveedor IN ('Nacional','Internacional'))
);

-- 3. CLIENTES
CREATE TABLE clientes(
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    cedula VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(100) UNIQUE,
    provincia VARCHAR(40),
    fecha_nacimiento DATE
);

-- 4. PRODUCTOS
CREATE TABLE productos(
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    tipo_producto VARCHAR(100) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,
    CHECK (stock_actual >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (tipo_producto IN ('Nacional','Importado')),
    CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prod_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5. EMPLEADOS
CREATE TABLE empleados(
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empleado VARCHAR(80) NOT NULL,
    cargo VARCHAR(40) NOT NULL,
    rol VARCHAR(20) NOT NULL,
    CHECK (rol IN ('Administrador','Gerente','Cajero','Vendedor','Auditor'))
);

-- 6. PROMOCIONES
CREATE TABLE promociones(
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_promocion VARCHAR(60) NOT NULL,
    descuento_porcentaje DECIMAL(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (descuento_porcentaje BETWEEN 0 AND 100),
    CHECK (fecha_fin >= fecha_inicio)
);

-- 7. VENTAS
CREATE TABLE ventas(
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_promocion INT,
    fecha DATE NOT NULL DEFAULT (CURDATE()),
    tipo_venta VARCHAR(20) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_venta DECIMAL(10,2) NOT NULL,
    CHECK (tipo_venta IN ('Mayorista','Minorista')),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_venta_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_venta_promocion FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion) ON UPDATE CASCADE ON DELETE SET NULL
);

-- 8. DETALLE_VENTA
CREATE TABLE detalle_venta(
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    precio_aplicado DECIMAL(10,2) NOT NULL,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    CHECK (cantidad > 0),
    CONSTRAINT fk_det_venta FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_det_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. DEVOLUCIONES
CREATE TABLE devoluciones(
    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    motivo VARCHAR(150),
    fecha_devolucion DATE NOT NULL DEFAULT (CURDATE()),
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    CHECK (cantidad > 0),
    CONSTRAINT fk_dev_venta FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dev_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 10. INVENTARIO
CREATE TABLE inventario(
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (tipo_movimiento IN ('Entrada','Salida')),
    CHECK (cantidad > 0),
    CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 11. COMPRAS
CREATE TABLE compras(
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT NOT NULL,
    fecha_compra DATE NOT NULL DEFAULT (CURDATE()),
    total_compra DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 12. DETALLE_COMPRA
CREATE TABLE detalle_compra(
    id_detalle_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CHECK (cantidad > 0),
    CONSTRAINT fk_detcompra_compra FOREIGN KEY (id_compra) REFERENCES compras(id_compra) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detcompra_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 13. AUDITORIA
CREATE TABLE auditoria(
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accion VARCHAR(20) NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,
    detalle TEXT
);

-- 14. QUEJAS
CREATE TABLE quejas(
    id_queja INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    descripcion VARCHAR(300) NOT NULL,
    fecha_queja DATE DEFAULT (CURDATE()),
    estado VARCHAR(20) DEFAULT 'Pendiente',
    CHECK (tipo IN ('Reclamo','Sugerencia')),
    CHECK (estado IN ('Pendiente','En proceso','Resuelta')),
    CONSTRAINT fk_queja_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 15. HISTORIAL_PRECIOS
CREATE TABLE historial_precios(
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historial_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 16. REGISTRO ACCESO
CREATE TABLE registro_accesos (
    id_acceso INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tabla_afectada VARCHAR(50) NOT NULL,
    detalle TEXT
);

-- =========================================================
-- DATOS DE PRUEBA
-- =========================================================

-- CATEGORIAS
INSERT INTO categorias (nombre_categoria, descripcion) VALUES
('Deportivo', 'Calzado para actividades deportivas en general'),
('Casual', 'Calzado de uso diario, comodo e informal'),
('Formal', 'Calzado de vestir para oficina y eventos'),
('Sandalias', 'Calzado abierto para clima calido'),
('Botas', 'Calzado alto para clima frio o trabajo pesado'),
('Infantil', 'Calzado disenado para ninos y ninas'),
('Running', 'Calzado especializado para correr'),
('Urbano', 'Calzado de moda estilo urbano/streetwear'),
('Outdoor', 'Calzado para senderismo y actividades al aire libre'),
('Plataforma', 'Calzado con suela elevada tipo plataforma');

-- PROVEEDORES
INSERT INTO proveedores (nombre_proveedor, pais, tipo_proveedor, telefono) VALUES
('Calzado Andino S.A.', 'Ecuador', 'Nacional', '042345678'),
('Curtidos del Austro', 'Ecuador', 'Nacional', '072456789'),
('Guangzhou Shoe Co.', 'China', 'Internacional', '861234567'),
('Calcados Brasil Ltda.', 'Brasil', 'Internacional', '551123456'),
('Manufacturas El Progreso', 'Ecuador', 'Nacional', '032567890'),
('Vietnam Footwear Group', 'Vietnam', 'Internacional', '841234567'),
('Industrias Colombianas de Cuero', 'Colombia', 'Internacional', '601234567'),
('Calzados Italia Srl.', 'Italia', 'Internacional', '391234567'),
('Textiles y Calzado Ambato', 'Ecuador', 'Nacional', '032678901'),
('American Shoes Inc.', 'Estados Unidos', 'Internacional', '13051234567');

-- EMPLEADOS
INSERT INTO empleados (nombre_empleado, cargo, rol) VALUES
('Maria Fernanda Torres', 'Gerente General', 'Gerente'),
('Carlos Andres Vega', 'Administrador de Sistema', 'Administrador'),
('Lucia Elizabeth Ramos', 'Cajera', 'Cajero'),
('Jose Luis Mendoza', 'Cajero', 'Cajero'),
('Andrea Paola Suarez', 'Vendedora', 'Vendedor'),
('Diego Fernando Chavez', 'Vendedor', 'Vendedor'),
('Gabriela Alejandra Ponce', 'Vendedora', 'Vendedor'),
('Pedro Pablo Zambrano', 'Vendedor', 'Vendedor'),
('Monica Isabel Cordova', 'Auditora Interna', 'Auditor'),
('Ricardo Javier Salazar', 'Vendedor', 'Vendedor');

-- CLIENTES
INSERT INTO clientes (cedula, nombre, apellido, telefono, correo, provincia, fecha_nacimiento) VALUES
('1686579303', 'Juan', 'Perez', '0924942603', 'juan.perez0@correo.com', 'Pichincha', '1990-03-12'),
('1796233790', 'Maria', 'Gonzalez', '0946913810', 'maria.gonzalez1@correo.com', 'Tungurahua', '1985-07-22'),
('1239670711', 'Luis', 'Rodriguez', '0928728463', 'luis.rodriguez2@correo.com', 'Guayas', '1992-11-05'),
('1726600539', 'Ana', 'Vasquez', '0983197857', 'ana.vasquez3@correo.com', 'Guayas', '1988-01-30'),
('1634036506', 'Pedro', 'Chavez', '0966629388', 'pedro.chavez4@correo.com', 'Pichincha', '1995-05-18'),
('1031994523', 'Carmen', 'Morales', '0922575562', 'carmen.morales5@correo.com', 'Tungurahua', '1979-09-09'),
('1249817734', 'Jorge', 'Ortiz', '0977827638', 'jorge.ortiz6@correo.com', 'Imbabura', '1991-12-25'),
('1028492780', 'Sofia', 'Castro', '0985329037', 'sofia.castro7@correo.com', 'Tungurahua', '1997-04-14'),
('1768820204', 'Miguel', 'Herrera', '0997226012', 'miguel.herrera8@correo.com', 'El Oro', '1983-08-02'),
('1450455977', 'Valentina', 'Jimenez', '0939587039', 'valentina.jimenez9@correo.com', 'Manabi', '1999-02-27'),
('1632719211', 'Fernando', 'Vera', '0947338124', 'fernando.vera10@correo.com', 'Pichincha', '1980-06-11'),
('1814763202', 'Camila', 'Zambrano', '0931429110', 'camila.zambrano11@correo.com', 'Chimborazo', '1994-10-19'),
('1365341213', 'Ricardo', 'Cedeno', '0947295260', 'ricardo.cedeno12@correo.com', 'Azuay', '1986-03-03'),
('1231191390', 'Daniela', 'Alvarado', '0955176955', 'daniela.alvarado13@correo.com', 'Guayas', '1993-07-07'),
('1099585092', 'Andres', 'Rosero', '0960992979', 'andres.rosero14@correo.com', 'Guayas', '1989-11-23'),
('1385451171', 'Paula', 'Guerrero', '0956164955', 'paula.guerrero15@correo.com', 'Imbabura', '1996-01-16'),
('1284027113', 'Diego', 'Villacis', '0915831819', 'diego.villacis16@correo.com', 'Manabi', '1982-09-29'),
('1575770529', 'Gabriela', 'Andrade', '0926753883', 'gabriela.andrade17@correo.com', 'Chimborazo', '1998-05-08'),
('1084611066', 'Santiago', 'Cevallos', '0984093639', 'santiago.cevallos18@correo.com', 'Loja', '1984-12-12'),
('1890566476', 'Isabella', 'Salazar', '0994374605', 'isabella.salazar19@correo.com', 'Imbabura', '2000-02-02'),
('1950746571', 'Marco', 'Pinto', '0958537831', 'marco.pinto20@correo.com', 'Imbabura', '1978-08-19'),
('1206468299', 'Lorena', 'Sanchez', '0919335534', 'lorena.sanchez21@correo.com', 'Pichincha', '1991-04-04'),
('1710026086', 'Esteban', 'Loor', '0940587988', 'esteban.loor22@correo.com', 'Loja', '1987-10-30'),
('1085675980', 'Priscila', 'Bravo', '0941244663', 'priscila.bravo23@correo.com', 'Guayas', '1995-06-06'),
('1408157429', 'David', 'Tapia', '0947308985', 'david.tapia24@correo.com', 'Manabi', '1990-01-01'),
('1682560971', 'Karla', 'Robles', '0958966946', 'karla.robles25@correo.com', 'Azuay', '1993-09-15'),
('1397478786', 'Alberto', 'Lascano', '0957683626', 'alberto.lascano26@correo.com', 'Tungurahua', '1981-03-21'),
('1719595113', 'Nicole', 'Freire', '0945833156', 'nicole.freire27@correo.com', 'Guayas', '1997-07-17'),
('1654049436', 'Roberto', 'Barros', '0995225343', 'roberto.barros28@correo.com', 'Azuay', '1986-11-11'),
('1573528321', 'Alexandra', 'Yepez', '0942857966', 'alexandra.yepez29@correo.com', 'Azuay', '1992-05-25');

-- PRODUCTOS
INSERT INTO productos (nombre_producto, tipo_producto, precio_unitario, stock_actual, stock_minimo, id_categoria, id_proveedor) VALUES
('Zapatilla Running Pro X', 'Importado', 89.99, 58, 9, 7, 8),
('Zapatilla Running Basico', 'Nacional', 45.50, 38, 15, 1, 9),
('Bota de Cuero Andina', 'Nacional', 75.00, 17, 8, 2, 6),
('Bota Industrial Reforzada', 'Nacional', 68.00, 50, 11, 2, 1),
('Sandalia Playera Clasica', 'Nacional', 22.00, 18, 8, 4, 5),
('Sandalia de Cuero Artesanal', 'Nacional', 28.50, 50, 8, 4, 10),
('Zapato Formal Oxford', 'Importado', 95.00, 60, 15, 3, 8),
('Zapato Formal Derby', 'Nacional', 70.00, 28, 9, 3, 8),
('Zapatilla Casual Urbana', 'Importado', 55.00, 41, 13, 8, 3),
('Zapatilla Casual Lona', 'Nacional', 32.00, 43, 14, 2, 9),
('Zapato Infantil Escolar', 'Nacional', 25.00, 61, 10, 6, 7),
('Zapatilla Infantil Deportiva', 'Importado', 30.00, 27, 13, 6, 4),
('Bota Outdoor Impermeable', 'Importado', 110.00, 21, 5, 9, 8),
('Zapatilla Trekking Montana', 'Importado', 98.00, 29, 15, 9, 2),
('Zapatilla Plataforma Chunky', 'Importado', 60.00, 64, 14, 10, 3),
('Sandalia Plataforma Verano', 'Nacional', 35.00, 59, 11, 10, 2),
('Zapatilla Skate Urbana', 'Nacional', 48.00, 69, 13, 8, 10),
('Zapato Mocasin Casual', 'Nacional', 52.00, 80, 5, 2, 5),
('Zapatilla Running Elite', 'Importado', 125.00, 78, 9, 7, 2),
('Bota Militar Urbana', 'Importado', 88.00, 24, 9, 5, 6);

-- PROMOCIONES
INSERT INTO promociones (nombre_promocion, descuento_porcentaje, fecha_inicio, fecha_fin) VALUES
('Black Friday Calzado', 25.00, '2025-01-01', '2025-01-16'),
('Rebajas de Temporada', 15.00, '2025-01-31', '2025-02-15'),
('Dia de la Madre', 10.00, '2025-03-02', '2025-03-17'),
('Regreso a Clases', 12.00, '2025-04-01', '2025-04-16'),
('Navidad Andina', 20.00, '2025-05-01', '2025-05-16'),
('Aniversario de la Tienda', 30.00, '2025-05-31', '2025-06-15'),
('Ciber Lunes', 18.00, '2025-06-30', '2025-07-15'),
('Liquidacion de Inventario', 35.00, '2025-07-30', '2025-08-14'),
('Promo San Valentin', 8.00, '2025-08-29', '2025-09-13'),
('Descuento Cliente Frecuente', 5.00, '2025-09-28', '2025-10-13');

-- VENTAS
INSERT INTO ventas (id_cliente, id_empleado, id_promocion, fecha, tipo_venta, subtotal, descuento, total_venta) VALUES
(14, 4, NULL, '2026-02-23', 'Minorista', 48.00, 0.00, 48.00),
(28, 8, 9, '2025-08-30', 'Minorista', 194.50, 15.56, 178.94),
(20, 5, NULL, '2026-05-11', 'Minorista', 367.50, 0.00, 367.50),
(3, 3, NULL, '2026-06-02', 'Minorista', 391.00, 0.00, 391.00),
(17, 10, NULL, '2026-03-21', 'Minorista', 963.00, 0.00, 963.00),
(15, 3, 2, '2026-01-15', 'Mayorista', 283.00, 42.45, 240.55),
(8, 3, NULL, '2026-01-19', 'Mayorista', 220.00, 0.00, 220.00),
(7, 7, 10, '2025-09-15', 'Minorista', 193.00, 9.65, 183.35),
(22, 6, NULL, '2025-12-09', 'Minorista', 474.00, 0.00, 474.00),
(8, 4, 8, '2026-04-27', 'Minorista', 340.00, 119.00, 221.00),
(26, 10, NULL, '2026-05-18', 'Mayorista', 759.98, 0.00, 759.98),
(16, 4, NULL, '2026-06-07', 'Minorista', 330.00, 0.00, 330.00),
(30, 10, NULL, '2026-02-11', 'Minorista', 253.00, 0.00, 253.00),
(2, 7, NULL, '2026-06-06', 'Minorista', 227.50, 0.00, 227.50),
(16, 7, NULL, '2025-10-09', 'Minorista', 579.50, 0.00, 579.50),
(13, 3, NULL, '2025-09-19', 'Minorista', 1092.50, 0.00, 1092.50),
(11, 5, 6, '2026-03-07', 'Minorista', 128.00, 38.40, 89.60),
(11, 10, NULL, '2026-07-03', 'Minorista', 667.00, 0.00, 667.00),
(5, 5, NULL, '2026-03-04', 'Minorista', 300.00, 0.00, 300.00),
(23, 5, NULL, '2025-08-07', 'Minorista', 268.00, 0.00, 268.00),
(29, 3, NULL, '2026-04-19', 'Minorista', 762.00, 0.00, 762.00),
(9, 10, 7, '2026-02-16', 'Mayorista', 264.00, 47.52, 216.48),
(18, 8, NULL, '2026-07-03', 'Mayorista', 553.50, 0.00, 553.50),
(5, 6, 5, '2026-01-02', 'Minorista', 60.00, 12.00, 48.00),
(22, 4, NULL, '2026-01-07', 'Minorista', 220.00, 0.00, 220.00),
(26, 10, 7, '2026-06-25', 'Minorista', 434.00, 78.12, 355.88),
(26, 8, 1, '2025-11-09', 'Minorista', 124.00, 31.00, 93.00),
(1, 8, 6, '2026-02-15', 'Minorista', 360.00, 108.00, 252.00),
(11, 3, 5, '2026-04-07', 'Minorista', 499.50, 99.90, 399.60),
(12, 8, NULL, '2025-11-26', 'Minorista', 694.00, 0.00, 694.00),
(1, 7, NULL, '2025-10-05', 'Minorista', 675.00, 0.00, 675.00),
(11, 8, NULL, '2026-02-04', 'Minorista', 639.00, 0.00, 639.00),
(7, 6, NULL, '2025-12-25', 'Minorista', 440.00, 0.00, 440.00),
(10, 6, NULL, '2026-07-07', 'Minorista', 490.00, 0.00, 490.00),
(20, 8, 8, '2025-11-23', 'Minorista', 622.50, 217.88, 404.62),
(11, 3, NULL, '2026-03-09', 'Minorista', 190.00, 0.00, 190.00),
(1, 3, 8, '2025-08-29', 'Minorista', 240.00, 84.00, 156.00),
(29, 8, NULL, '2025-12-23', 'Minorista', 22.00, 0.00, 22.00),
(29, 10, NULL, '2026-05-14', 'Minorista', 142.50, 0.00, 142.50),
(15, 3, NULL, '2026-05-06', 'Minorista', 396.00, 0.00, 396.00),
(25, 6, NULL, '2025-10-22', 'Minorista', 395.50, 0.00, 395.50),
(27, 8, 9, '2025-11-01', 'Minorista', 330.00, 26.40, 303.60),
(9, 5, 9, '2026-05-27', 'Mayorista', 220.00, 17.60, 202.40),
(23, 4, 7, '2026-01-19', 'Minorista', 562.00, 101.16, 460.84),
(29, 10, NULL, '2026-06-27', 'Minorista', 794.96, 0.00, 794.96),
(28, 10, NULL, '2025-10-01', 'Minorista', 70.00, 0.00, 70.00),
(9, 6, NULL, '2025-12-20', 'Minorista', 662.50, 0.00, 662.50),
(1, 6, NULL, '2025-08-02', 'Mayorista', 398.00, 0.00, 398.00),
(13, 5, 6, '2026-01-16', 'Minorista', 263.00, 78.90, 184.10),
(16, 3, NULL, '2026-06-11', 'Minorista', 145.00, 0.00, 145.00);

-- DETALLE_VENTA
INSERT INTO detalle_venta (cantidad, precio_aplicado, id_venta, id_producto) VALUES
(1, 48.00, 1, 17),
(5, 28.50, 2, 6),
(1, 52.00, 2, 18),
(2, 70.00, 3, 8),
(5, 45.50, 3, 2),
(5, 22.00, 4, 5),
(2, 88.00, 4, 20),
(3, 35.00, 4, 16),
(3, 95.00, 5, 7),
(4, 32.00, 5, 10),
(5, 110.00, 5, 13),
(1, 70.00, 6, 8),
(1, 125.00, 6, 19),
(1, 88.00, 6, 20),
(4, 55.00, 7, 9),
(1, 98.00, 8, 14),
(1, 95.00, 8, 7),
(4, 45.50, 9, 2),
(3, 68.00, 9, 4),
(1, 88.00, 9, 20),
(1, 60.00, 10, 15),
(4, 70.00, 10, 8),
(2, 89.99, 11, 1),
(4, 75.00, 11, 3),
(4, 70.00, 11, 8),
(3, 110.00, 12, 13),
(2, 52.00, 13, 18),
(3, 35.00, 13, 16),
(2, 22.00, 13, 5),
(5, 45.50, 14, 2),
(5, 75.00, 15, 3),
(1, 28.50, 15, 6),
(2, 88.00, 15, 20),
(5, 45.50, 16, 2),
(5, 75.00, 16, 3),
(5, 98.00, 16, 14),
(4, 32.00, 17, 10),
(2, 68.00, 18, 4),
(5, 75.00, 18, 3),
(3, 52.00, 18, 18),
(5, 60.00, 19, 15),
(2, 52.00, 20, 18),
(3, 32.00, 20, 10),
(1, 68.00, 20, 4),
(3, 95.00, 21, 7),
(5, 25.00, 21, 11),
(4, 88.00, 21, 20),
(2, 22.00, 22, 5),
(4, 55.00, 22, 9),
(3, 22.00, 23, 5),
(5, 52.00, 23, 18),
(5, 45.50, 23, 2),
(2, 30.00, 24, 12),
(2, 88.00, 25, 20),
(2, 22.00, 25, 5),
(3, 98.00, 26, 14),
(2, 70.00, 26, 8),
(2, 30.00, 27, 12),
(2, 32.00, 27, 10),
(4, 30.00, 28, 12),
(5, 48.00, 28, 17),
(5, 45.50, 29, 2),
(4, 68.00, 29, 4),
(3, 68.00, 30, 4),
(1, 110.00, 30, 13),
(4, 95.00, 30, 7),
(1, 95.00, 31, 7),
(3, 30.00, 31, 12),
(5, 98.00, 31, 14),
(3, 98.00, 32, 14),
(5, 25.00, 32, 11),
(2, 110.00, 32, 13),
(5, 88.00, 33, 20),
(5, 98.00, 34, 14),
(3, 35.00, 35, 16),
(5, 28.50, 35, 6),
(5, 75.00, 35, 3),
(2, 95.00, 36, 7),
(4, 60.00, 37, 15),
(1, 22.00, 38, 5),
(5, 28.50, 39, 6),
(5, 48.00, 40, 17),
(3, 52.00, 40, 18),
(4, 60.00, 41, 15),
(3, 28.50, 41, 6),
(2, 35.00, 41, 16),
(3, 60.00, 42, 15),
(2, 75.00, 42, 3),
(2, 110.00, 43, 13),
(4, 45.50, 44, 2),
(4, 95.00, 44, 7),
(3, 110.00, 45, 13),
(3, 35.00, 45, 16),
(4, 89.99, 45, 1),
(2, 35.00, 46, 16),
(2, 110.00, 47, 13),
(5, 28.50, 47, 6),
(5, 60.00, 47, 15),
(2, 98.00, 48, 14),
(1, 22.00, 48, 5),
(3, 60.00, 48, 15),
(3, 55.00, 49, 9),
(1, 98.00, 49, 14),
(1, 70.00, 50, 8),
(1, 75.00, 50, 3);

-- DEVOLUCIONES
INSERT INTO devoluciones (cantidad, motivo, fecha_devolucion, id_venta, id_producto) VALUES
    (1, 'Color distinto al pedido', '2025-10-14', 15, 6),
    (1, 'Talla incorrecta', '2026-06-22', 12, 13),
    (1, 'Producto no coincide con la descripcion', '2025-09-06', 2, 18),
    (1, 'Producto defectuoso', '2026-01-02', 38, 5),
    (1, 'Producto defectuoso', '2025-12-21', 9, 20),
    (2, 'Producto defectuoso', '2025-10-22', 15, 3),
    (1, 'Suela despegada', '2025-09-24', 8, 7),
    (2, 'Suela despegada', '2026-02-17', 28, 17),
    (2, 'Talla incorrecta', '2025-11-05', 41, 16),
    (2, 'Cambio por otro modelo', '2026-01-21', 7, 9),
    (2, 'Suela despegada', '2026-01-05', 33, 20),
    (2, 'Color distinto al pedido', '2026-02-18', 13, 16),
    (1, 'Costura descosida', '2026-02-25', 28, 12),
    (2, 'Cambio por otro modelo', '2026-01-26', 44, 2),
    (2, 'Suela despegada', '2025-10-23', 15, 20),
    (1, 'Producto defectuoso', '2025-08-07', 48, 14),
    (2, 'Cliente se arrepintio de la compra', '2026-03-01', 22, 5),
    (2, 'Producto no coincide con la descripcion', '2026-05-03', 10, 8),
    (1, 'Cambio por otro modelo', '2026-03-23', 36, 7),
    (2, 'Color distinto al pedido', '2025-12-28', 47, 13);

-- INVENTARIO 
INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento) VALUES
    (7, 'Salida', 21, '2026-01-14 09:00:00'), (9, 'Salida', 40, '2026-07-02 09:00:00'),
    (17, 'Entrada', 10, '2026-03-06 09:00:00'), (14, 'Salida', 40, '2026-03-06 09:00:00'),
    (16, 'Salida', 33, '2026-06-29 09:00:00'), (3, 'Salida', 19, '2025-12-12 09:00:00'),
    (8, 'Salida', 47, '2025-09-13 09:00:00'), (12, 'Salida', 40, '2025-10-09 09:00:00'),
    (12, 'Salida', 40, '2026-01-19 09:00:00'), (12, 'Salida', 22, '2026-02-01 09:00:00'),
    (9, 'Entrada', 12, '2026-03-31 09:00:00'), (11, 'Entrada', 39, '2026-04-04 09:00:00'),
    (7, 'Entrada', 35, '2026-02-16 09:00:00'), (19, 'Salida', 11, '2026-03-30 09:00:00'),
    (10, 'Entrada', 28, '2026-04-07 09:00:00'), (10, 'Entrada', 50, '2025-10-07 09:00:00'),
    (5, 'Salida', 7, '2026-06-10 09:00:00'), (18, 'Salida', 49, '2026-05-04 09:00:00'),
    (16, 'Entrada', 5, '2025-09-17 09:00:00'), (10, 'Salida', 35, '2025-11-24 09:00:00');

-- COMPRAS 
INSERT INTO compras (id_proveedor, fecha_compra, total_compra) VALUES
    (6, '2026-03-06', 1320.0), (8, '2026-04-11', 1650.0), (2, '2026-05-12', 462.0),
    (10, '2026-01-04', 546.0), (9, '2025-11-07', 3292.8), (8, '2026-01-07', 3374.1),
    (2, '2026-02-22', 2091.0), (9, '2026-05-01', 1241.77), (8, '2025-10-11', 1862.7),
    (5, '2025-10-19', 1638.0);

-- DETALLE_COMPRA
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario) VALUES
    (1, 9, 40, 33.0), (2, 13, 25, 66.0), (3, 5, 35, 13.2), (4, 8, 13, 42.0),
    (5, 20, 22, 52.8), (5, 8, 24, 42.0), (5, 17, 39, 28.8), (6, 14, 29, 58.8),
    (6, 10, 40, 19.2), (6, 2, 33, 27.3), (7, 7, 15, 57.0), (7, 9, 17, 33.0),
    (7, 3, 15, 45.0), (8, 1, 23, 53.99), (9, 2, 19, 27.3), (9, 8, 32, 42.0),
    (10, 8, 39, 42.0);

-- =========================================================
-- CONSULTAS SQL Y SUBCONSULTAS
-- =========================================================

-- Listado de clientes
SELECT id_cliente AS IdCliente, nombre AS Nombres, apellido AS Apellidos,
       telefono AS Telefono, correo AS Correo, provincia AS Provincia
FROM clientes;

-- Productos disponibles
SELECT id_producto AS IdProducto, nombre_producto AS NombreProducto,
       tipo_producto AS TipoProducto, precio_unitario AS Precio, stock_actual AS StockActual
FROM productos
WHERE stock_actual > 0;

-- Ventas por fecha
SELECT v.id_venta AS IdVenta, v.fecha AS FechaVenta,
       CONCAT(c.nombre, ' ', c.apellido) AS Cliente, v.total_venta AS TotalVenta
FROM ventas v
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
ORDER BY v.fecha DESC;

-- Proveedores registrados
SELECT id_proveedor AS IdProveedor, nombre_proveedor AS NombreProveedor,
       pais AS Pais, tipo_proveedor AS TipoProveedor, telefono AS Telefono
FROM proveedores;

-- Empleados por rol
SELECT id_empleado AS IdEmpleado, nombre_empleado AS NombreEmpleado, cargo AS Cargo, rol AS Rol
FROM empleados
ORDER BY rol;

-- Clientes con sus compras (JOIN)
SELECT CONCAT(c.nombre, ' ', c.apellido) AS Cliente, v.fecha AS FechaVenta,
       v.total_venta AS TotalVenta, v.tipo_venta AS TipoVenta
FROM clientes c
JOIN ventas v 
	ON c.id_cliente = v.id_cliente;

-- Ventas con vendedor (JOIN)
SELECT v.id_venta AS IdVenta, CONCAT(c.nombre, ' ', c.apellido) AS Cliente,
       e.nombre_empleado AS Vendedor, v.fecha AS FechaVenta, v.total_venta AS TotalVenta
FROM ventas v
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
JOIN empleados e 
	ON e.id_empleado = v.id_empleado;

-- Detalle de productos vendidos (JOIN)
SELECT dv.id_venta AS IdVenta, p.nombre_producto AS Producto, dv.cantidad AS Cantidad,
       dv.precio_aplicado AS PrecioUnitario, (dv.cantidad * dv.precio_aplicado) AS Subtotal
FROM detalle_venta dv
JOIN productos p 
	ON p.id_producto = dv.id_producto;

-- Productos con proveedor (JOIN)
SELECT p.nombre_producto AS Producto, p.tipo_producto AS TipoProducto,
       pr.nombre_proveedor AS Proveedor, pr.pais AS PaisProveedor
FROM productos p
JOIN proveedores pr 
	ON pr.id_proveedor = p.id_proveedor;

-- Devoluciones con cliente y producto (JOIN)
SELECT CONCAT(c.nombre, ' ', c.apellido) AS Cliente, p.nombre_producto AS Producto,
       d.fecha_devolucion AS FechaDevolucion, d.motivo AS Motivo, d.cantidad AS Cantidad
FROM devoluciones d
JOIN ventas v 
	ON v.id_venta = d.id_venta
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
JOIN productos p 
	ON p.id_producto = d.id_producto;

-- Total vendido por vendedor (GROUP BY)
SELECT e.nombre_empleado AS Vendedor, COUNT(v.id_venta) AS CantidadVentas,
       SUM(v.total_venta) AS TotalVendido
FROM ventas v
JOIN empleados e ON e.id_empleado = v.id_empleado
GROUP BY e.id_empleado, e.nombre_empleado;

-- Productos mas vendidos (GROUP BY)
SELECT p.nombre_producto AS Producto, SUM(dv.cantidad) AS TotalUnidadesVendidas
FROM detalle_venta dv
JOIN productos p 
	ON p.id_producto = dv.id_producto
GROUP BY p.nombre_producto;

-- Ventas por mes (GROUP BY)
SELECT MONTH(fecha) AS Mes, COUNT(id_venta) AS TotalVentas, SUM(total_venta) AS MontoTotal
FROM ventas
GROUP BY MONTH(fecha);

-- Compras por cliente (GROUP BY)
SELECT CONCAT(c.nombre, ' ', c.apellido) AS Cliente, COUNT(v.id_venta) AS CantidadCompras,
       SUM(v.total_venta) AS MontoAcumulado
FROM clientes c
JOIN ventas v 
	ON v.id_cliente = c.id_cliente
GROUP BY c.nombre, c.apellido;

-- Devoluciones por vendedor (GROUP BY)
SELECT e.nombre_empleado AS Vendedor, COUNT(d.id_devolucion) AS TotalDevoluciones
FROM devoluciones d
JOIN ventas v 
	ON v.id_venta = d.id_venta
JOIN empleados e 
	ON e.id_empleado = v.id_empleado
GROUP BY e.nombre_empleado;

-- Clientes con compras superiores al promedio (Subconsulta)
SELECT CONCAT(c.nombre, ' ', c.apellido) AS Cliente, SUM(v.total_venta) AS TotalComprado
FROM clientes c
JOIN ventas v 
	ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING SUM(v.total_venta) > (
    SELECT AVG(total_cliente)
    FROM (SELECT SUM(total_venta) AS total_cliente FROM ventas GROUP BY id_cliente) AS promedio_clientes
);

-- Productos con precio mayor al promedio (Subconsulta)
SELECT nombre_producto AS Producto, precio_unitario AS Precio
FROM productos
WHERE precio_unitario > (SELECT AVG(precio_unitario) FROM productos);

-- Vendedores con ventas superiores al promedio (Subconsulta)
SELECT e.nombre_empleado AS Vendedor, SUM(v.total_venta) AS TotalVendido
FROM empleados e
JOIN ventas v 
	ON e.id_empleado = v.id_empleado
GROUP BY e.id_empleado, e.nombre_empleado
HAVING SUM(v.total_venta) > (
    SELECT AVG(total_vendido)
    FROM (SELECT SUM(total_venta) AS total_vendido FROM ventas GROUP BY id_empleado) AS promedio
);

-- Productos que nunca se han vendido (Subconsulta)
SELECT id_producto AS IdProducto, nombre_producto AS NombreProducto, stock_actual AS StockActual
FROM productos
WHERE id_producto NOT IN (SELECT DISTINCT id_producto FROM detalle_venta);

-- Clientes que no han realizado compras (Subconsulta)
SELECT id_cliente AS IdCliente, nombre AS Nombres, apellido AS Apellidos, telefono AS Telefono
FROM clientes
WHERE id_cliente NOT IN (SELECT DISTINCT id_cliente FROM ventas);

-- =========================================================
-- VISTAS 
-- =========================================================

-- Clientes Frecuentes
CREATE OR REPLACE VIEW vw_clientes_frecuentes AS
SELECT c.id_cliente AS IdCliente, c.nombre AS Nombres, c.apellido AS Apellidos,
       c.provincia AS Provincia, COUNT(v.id_venta) AS TotalCompras,
       SUM(v.total_venta) AS MontoAcumulado
FROM clientes c
JOIN ventas v 
	ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente;

SELECT * FROM vw_clientes_frecuentes
ORDER BY TotalCompras DESC;

-- Ventas Consolidadas
CREATE OR REPLACE VIEW vw_ventas_consolidadas AS
SELECT v.id_venta AS IdVenta, v.fecha AS FechaVenta,
       CONCAT(c.nombre, ' ', c.apellido) AS Cliente, e.nombre_empleado AS Vendedor,
       v.tipo_venta AS TipoVenta, v.subtotal AS Subtotal, v.descuento AS Descuento,
       v.total_venta AS Total
FROM ventas v
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
JOIN empleados e 
	ON e.id_empleado = v.id_empleado;

SELECT * FROM vw_ventas_consolidadas;

-- Productos con Bajo Stock
CREATE OR REPLACE VIEW vw_productos_bajo_stock AS
SELECT p.id_producto AS IdProducto, p.nombre_producto AS NombreProducto,
       cat.nombre_categoria AS Categoria, p.stock_actual AS StockActual,
       p.stock_minimo AS StockMinimo
FROM productos p
JOIN categorias cat ON cat.id_categoria = p.id_categoria
WHERE p.stock_actual < p.stock_minimo;

SELECT * FROM vw_productos_bajo_stock;

-- Promociones Aplicadas
CREATE OR REPLACE VIEW vw_promociones_aplicadas AS
SELECT v.id_venta AS IdVenta, CONCAT(c.nombre, ' ', c.apellido) AS Cliente,
       pr.nombre_promocion AS Promocion, v.descuento AS DescuentoAplicado, v.fecha AS FechaVenta
FROM ventas v
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
JOIN promociones pr 
	ON pr.id_promocion = v.id_promocion
WHERE v.id_promocion IS NOT NULL;

SELECT * FROM vw_promociones_aplicadas;

-- Devoluciones 
CREATE OR REPLACE VIEW vw_devoluciones AS
SELECT d.id_devolucion AS IdDevolucion, d.fecha_devolucion AS Fecha,
       CONCAT(c.nombre, ' ', c.apellido) AS Cliente, p.nombre_producto AS Producto,
       d.cantidad AS Cantidad, d.motivo AS Motivo
FROM devoluciones d
JOIN ventas v 
	ON v.id_venta = d.id_venta
JOIN clientes c 
	ON c.id_cliente = v.id_cliente
JOIN productos p 
	ON p.id_producto = d.id_producto;

SELECT * FROM vw_devoluciones;

-- Desempeño de Vendedores
CREATE OR REPLACE VIEW vw_desempeno_vendedores AS
SELECT
    e.id_empleado AS IdEmpleado,
    e.nombre_empleado AS NombreEmpleado,
    COUNT(v.id_venta) AS TotalVentas,
    COALESCE(SUM(v.total_venta), 0) AS MontoGenerado,
    (SELECT COUNT(*) FROM devoluciones d
     JOIN ventas v2 ON v2.id_venta = d.id_venta
     WHERE v2.id_empleado = e.id_empleado) AS TotalDevoluciones
FROM empleados e
LEFT JOIN ventas v 
	ON v.id_empleado = e.id_empleado
WHERE e.rol IN ('Vendedor', 'Cajero')
GROUP BY e.id_empleado, e.nombre_empleado;

SELECT * FROM vw_desempeno_vendedores

-- =========================================================
-- FUNCIONES 
-- =========================================================

-- 1 Calcular IVA
DELIMITER $$
CREATE FUNCTION fn_calcular_iva(p_monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_monto_total DECIMAL(10,2);
    IF p_monto IS NULL OR p_monto < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto no puede ser nulo ni negativo';
    END IF;
    SET v_monto_total = ROUND(p_monto * 0.15, 2);
    RETURN v_monto_total;
END $$
DELIMITER ;

SELECT fn_calcular_iva(100);

DELIMITER $$
-- Calcular Descuento 
CREATE FUNCTION fn_calcular_descuento(p_monto DECIMAL(10,2), p_id_promocion INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2);
    SELECT descuento_porcentaje INTO v_porcentaje
    FROM promociones
    WHERE id_promocion = p_id_promocion
    LIMIT 1;

    RETURN ROUND(p_monto * (v_porcentaje / 100), 2);
END $$
DELIMITER ;

SELECT fn_calcular_descuento(300, 1) AS descuento_promocion_1;

DELIMITER $$
-- Calcular Edad 
CREATE FUNCTION fn_calcular_edad(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_fecha_nac DATE;
    DECLARE v_edad INT;

    SELECT fecha_nacimiento INTO v_fecha_nac
    FROM clientes
    WHERE id_cliente = p_id_cliente
    LIMIT 1;

    IF v_fecha_nac IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe o no tiene fecha de nacimiento registrada';
    END IF;

    SET v_edad = TIMESTAMPDIFF(YEAR, v_fecha_nac, CURDATE());
    RETURN v_edad;
END $$
DELIMITER ;

SELECT fn_calcular_edad(1) AS edad_cliente_1;

DELIMITER $$
-- Calcular Comisión 
CREATE FUNCTION fn_calcular_comision(p_id_empleado INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_vendido DECIMAL(12,2);

    IF NOT EXISTS (SELECT 1 FROM ventas WHERE id_empleado = p_id_empleado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no tiene ventas registradas';
    END IF;

    SELECT SUM(total_venta) INTO v_total_vendido
    FROM ventas
    WHERE id_empleado = p_id_empleado;

    RETURN ROUND(v_total_vendido * 0.05, 2);
END $$
DELIMITER ;

SELECT fn_calcular_comision(6) AS comision_empleado_6;

DELIMITER $$
-- Productos Bajo Stock 
CREATE PROCEDURE sp_productos_bajo_stock()
BEGIN
    SELECT p.id_producto, p.nombre_producto, p.stock_actual, p.stock_minimo
    FROM productos p
    WHERE p.stock_actual < p.stock_minimo;
END $$
DELIMITER ;

CALL sp_productos_bajo_stock();

DELIMITER $$
-- Clientes Frecuentes
CREATE PROCEDURE sp_clientes_frecuentes(IN p_min_compras INT)
BEGIN
    SELECT c.id_cliente,
           CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
           COUNT(v.id_venta) AS total_compras,
           SUM(v.total_venta) AS monto_acumulado
    FROM clientes c
    JOIN ventas v ON v.id_cliente = c.id_cliente
    GROUP BY c.id_cliente, c.nombre, c.apellido
    HAVING COUNT(v.id_venta) >= p_min_compras;
END $$
DELIMITER ;

CALL sp_clientes_frecuentes(2);

-- =========================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =========================================================
-- 1 Registrar Cliente
DELIMITER $$
CREATE PROCEDURE sp_registrar_cliente(
    IN p_cedula VARCHAR(10), IN p_nombre VARCHAR(60), IN p_apellido VARCHAR(60),
    IN p_telefono VARCHAR(15), IN p_correo VARCHAR(100), IN p_provincia VARCHAR(40),
    IN p_fecha_nacimiento DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM clientes WHERE cedula = p_cedula OR correo = p_correo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un cliente registrado con esa cedula o correo';
    END IF;

    INSERT INTO clientes (cedula, nombre, apellido, telefono, correo, provincia, fecha_nacimiento)
    VALUES (p_cedula, p_nombre, p_apellido, p_telefono, p_correo, p_provincia, p_fecha_nacimiento);
END $$
DELIMITER ;

CALL sp_registrar_cliente('1750894512', 'Joel', 'Acosta', '0924942603', 'joel.acosta@correo.com', 'Pichincha', '2004-02-25');
SELECT * FROM clientes WHERE nombre = 'Joel';


-- 2 Registrar Producto
DELIMITER $$
CREATE PROCEDURE sp_registrar_producto(
    IN p_nombre VARCHAR(100), IN p_tipo_producto VARCHAR(20), IN p_precio DECIMAL(10,2),
    IN p_stock INT, IN p_stock_minimo INT, IN p_id_categoria INT, IN p_id_proveedor INT
)
BEGIN
    IF p_tipo_producto NOT IN ('Nacional', 'Importado') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_producto debe ser Nacional o Importado';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM categorias WHERE id_categoria = p_id_categoria) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoria no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM proveedores WHERE id_proveedor = p_id_proveedor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor no existe';
    END IF;

    INSERT INTO productos (nombre_producto, tipo_producto, precio_unitario, stock_actual, stock_minimo, id_categoria, id_proveedor)
    VALUES (p_nombre, p_tipo_producto, p_precio, p_stock, p_stock_minimo, p_id_categoria, p_id_proveedor);
END $$
DELIMITER ;

CALL sp_registrar_producto('Zapatilla Urbana Nova', 'Importado', 62.50, 30, 10, 8, 3);
SELECT * FROM productos WHERE nombre_producto = 'Zapatilla Urbana Nova';

-- 3 Registrar Venta
DELIMITER $$
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente INT, IN p_id_empleado INT, IN p_id_producto INT,
    IN p_tipo_venta VARCHAR(20), IN p_cantidad INT, IN p_id_promocion INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_descuento_pct DECIMAL(5,2) DEFAULT 0;
    DECLARE v_descuento DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_id_venta INT;

    SELECT precio_unitario, stock_actual INTO v_precio, v_stock
    FROM productos
    WHERE id_producto = p_id_producto
    FOR UPDATE;

    IF v_precio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    END IF;
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para el producto.';
    END IF;

    SET v_subtotal = v_precio * p_cantidad;

    IF p_id_promocion IS NOT NULL THEN
        SELECT descuento_porcentaje INTO v_descuento_pct
        FROM promociones
        WHERE id_promocion = p_id_promocion
          AND CURDATE() BETWEEN fecha_inicio AND fecha_fin;

        IF v_descuento_pct IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La promocion no existe o no esta vigente';
        END IF;
    END IF;

    SET v_descuento = v_subtotal * (v_descuento_pct / 100);
    SET v_total = v_subtotal - v_descuento;

    INSERT INTO ventas (id_cliente, id_empleado, id_promocion, fecha, tipo_venta, subtotal, descuento, total_venta)
    VALUES (p_id_cliente, p_id_empleado, p_id_promocion, CURDATE(), p_tipo_venta, v_subtotal, v_descuento, v_total);

    SET v_id_venta = LAST_INSERT_ID();

    INSERT INTO detalle_venta (cantidad, precio_aplicado, id_venta, id_producto)
    VALUES (p_cantidad, v_precio, v_id_venta, p_id_producto);
END $$
DELIMITER ;

CALL sp_registrar_venta(2, 5, 9, 'Minorista', 2, NULL);
SELECT * FROM ventas WHERE id_cliente = 2;

-- 4 Registrar Devolución
DELIMITER $$
CREATE PROCEDURE sp_registrar_devolucion(
    IN p_cantidad INT, IN p_motivo VARCHAR(150), IN p_id_venta INT, IN p_id_producto INT
)
BEGIN
    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'la cantidad debe ser mayor a cero';
    END IF;

    INSERT INTO devoluciones (cantidad, motivo, fecha_devolucion, id_venta, id_producto)
    VALUES (p_cantidad, p_motivo, CURDATE(), p_id_venta, p_id_producto);
END $$
DELIMITER ;

CALL sp_registrar_devolucion(1, 'Talla incorrecta', 5, 3);
SELECT * FROM devoluciones WHERE motivo = 'Talla incorrecta';

-- 5 Aplicar Promoción 
DELIMITER $$
CREATE PROCEDURE sp_aplicar_promocion(
    IN p_id_promocion INT, IN p_monto DECIMAL(10,2)
)
BEGIN
    DECLARE v_pct DECIMAL(5,2);
    DECLARE v_descuento DECIMAL(10,2);

    SELECT descuento_porcentaje INTO v_pct
    FROM promociones
    WHERE id_promocion = p_id_promocion
      AND CURDATE() BETWEEN fecha_inicio AND fecha_fin;

    IF v_pct IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La promocion no existe o no esta vigente';
    END IF;

    SET v_descuento = p_monto * (v_pct / 100);

    SELECT v_pct AS PorcentajeAplicado, p_monto AS MontoOriginal, v_descuento AS DescuentoCalculado;
END $$
DELIMITER ;

-- CASO ESPECIAL 
UPDATE promociones 
SET fecha_inicio = '2026-07-01', 
    fecha_fin = '2026-12-31' 
WHERE id_promocion = 6;

CALL sp_aplicar_promocion(6, 300.00);

-- 6 Calcular Ventas Mensuales
DELIMITER $$
CREATE PROCEDURE sp_calcular_ventas_mensuales()
BEGIN
    SELECT MONTH(fecha) AS Mes, SUM(total_venta) AS TotalVentas
    FROM ventas
    GROUP BY MONTH(fecha)
    ORDER BY Mes;
END $$
DELIMITER ;

CALL sp_calcular_ventas_mensuales();

-- 7 Registrar Proveedor
DELIMITER $$
CREATE PROCEDURE sp_registrar_proveedor(
    IN p_nombre VARCHAR(100), IN p_pais VARCHAR(100), IN p_tipo_proveedor VARCHAR(50), IN p_telefono VARCHAR(15)
)
BEGIN
    IF p_tipo_proveedor NOT IN ('Nacional', 'Internacional') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_proveedor debe ser Nacional o Internacional';
    END IF;

    INSERT INTO proveedores (nombre_proveedor, pais, tipo_proveedor, telefono)
    VALUES (p_nombre, p_pais, p_tipo_proveedor, p_telefono);
END $$
DELIMITER ;

CALL sp_registrar_proveedor('Cueros del Pacifico S.A.', 'Ecuador', 'Nacional', '042998877');
SELECT * FROM proveedores WHERE nombre_proveedor = 'Cueros del Pacifico S.A.';

-- 8 Actualizar Inventario
DELIMITER $$
CREATE PROCEDURE sp_actualizar_inventario(
    IN p_id_producto INT, IN p_tipo_movimiento VARCHAR(20), IN p_cantidad INT
)
BEGIN
    DECLARE v_stock_actual INT;

    IF p_tipo_movimiento NOT IN ('Entrada', 'Salida') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo_movimiento debe ser Entrada o Salida';
    END IF;

    SELECT stock_actual INTO v_stock_actual FROM productos WHERE id_producto = p_id_producto FOR UPDATE;
    IF v_stock_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe';
    END IF;

    IF p_tipo_movimiento = 'Salida' AND v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para realizar la salida';
    END IF;

    INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento)
    VALUES (p_id_producto, p_tipo_movimiento, p_cantidad, NOW());

    IF p_tipo_movimiento = 'Entrada' THEN
        UPDATE productos SET stock_actual = stock_actual + p_cantidad WHERE id_producto = p_id_producto;
    ELSE
        UPDATE productos SET stock_actual = stock_actual - p_cantidad WHERE id_producto = p_id_producto;
    END IF;
END $$
DELIMITER ;

CALL sp_actualizar_inventario(9, 'Entrada', 15);
SELECT id_producto, nombre_producto, stock_actual FROM productos WHERE id_producto = 9;

-- 9 Registrar Queja
DELIMITER $$
CREATE PROCEDURE sp_registrar_queja(
    IN p_id_cliente INT, IN p_tipo VARCHAR(20), IN p_descripcion VARCHAR(300)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = p_id_cliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no existe';
    END IF;
    IF p_tipo NOT IN ('Reclamo', 'Sugerencia') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tipo debe ser Reclamo o Sugerencia';
    END IF;

    INSERT INTO quejas (id_cliente, tipo, descripcion, fecha_queja, estado)
    VALUES (p_id_cliente, p_tipo, p_descripcion, CURDATE(), 'Pendiente');
END $$
DELIMITER ;

CALL sp_registrar_queja(4, 'Reclamo', 'El producto llego con la caja abierta');
SELECT * FROM quejas WHERE id_cliente = 4;

-- 10 Registrar Auditoría
DELIMITER $$
CREATE PROCEDURE sp_registrar_auditoria(
    IN p_usuario VARCHAR(50), IN p_accion VARCHAR(20), IN p_tabla_afectada VARCHAR(50), IN p_detalle VARCHAR(500)
)
BEGIN
    INSERT INTO auditoria (usuario, fecha_hora, accion, tabla_afectada, detalle)
    VALUES (p_usuario, NOW(), p_accion, p_tabla_afectada, p_detalle);
END $$
DELIMITER ;
-- =========================================================
-- TRIGGERS
-- =========================================================
-- 1 Auditoría INSERT sobre Clientes
DELIMITER $$
CREATE TRIGGER trg_auditoria_insert_clientes
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (usuario, fecha_hora, accion, tabla_afectada, detalle)
    VALUES (
        CURRENT_USER(), NOW(), 'INSERT', 'clientes',
        CONCAT('Cliente creado: id=', NEW.id_cliente,
               ', cedula=', NEW.cedula,
               ', nombre=', NEW.nombre, ' ', NEW.apellido,
               ', telefono=', COALESCE(NEW.telefono, 'N/A'),
               ', correo=', COALESCE(NEW.correo, 'N/A'),
               ', provincia=', COALESCE(NEW.provincia, 'N/A'),
               ', fecha_nacimiento=', COALESCE(NEW.fecha_nacimiento, 'N/A'))
    );
END $$
DELIMITER ;

-- Ejemplo 1
INSERT INTO clientes (cedula, nombre, apellido, telefono, correo, provincia, fecha_nacimiento)
VALUES ('1799887766', 'Mateo', 'Salinas', '0991122334', 'mateo.salinas@correo.com', 'Guayas', '1998-04-10');

SELECT * FROM auditoria WHERE tabla_afectada = 'clientes' AND accion = 'INSERT' ORDER BY id_auditoria DESC LIMIT 1;

-- 2 Auditoría UPDATE sobre Clientes
DELIMITER $$
CREATE TRIGGER trg_auditoria_update_clientes
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (usuario, fecha_hora, accion, tabla_afectada, detalle)
    VALUES (
        CURRENT_USER(), NOW(), 'UPDATE', 'clientes',
        CONCAT('Cliente id=', NEW.id_cliente,
               ' | ANTES: cedula=', OLD.cedula, ', nombre=', OLD.nombre, ' ', OLD.apellido,
               ', telefono=', COALESCE(OLD.telefono, 'N/A'), ', correo=', COALESCE(OLD.correo, 'N/A'),
               ', provincia=', COALESCE(OLD.provincia, 'N/A'),
               ', fecha_nacimiento=', COALESCE(OLD.fecha_nacimiento, 'N/A'),
               ' | DESPUES: cedula=', NEW.cedula, ', nombre=', NEW.nombre, ' ', NEW.apellido,
               ', telefono=', COALESCE(NEW.telefono, 'N/A'), ', correo=', COALESCE(NEW.correo, 'N/A'),
               ', provincia=', COALESCE(NEW.provincia, 'N/A'),
               ', fecha_nacimiento=', COALESCE(NEW.fecha_nacimiento, 'N/A'))
    );
END $$
DELIMITER ;

-- Ejemplo 2 
UPDATE clientes SET telefono = '0987001122' WHERE cedula = '1799887766';

SELECT * FROM auditoria WHERE tabla_afectada = 'clientes' AND accion = 'UPDATE' ORDER BY id_auditoria DESC LIMIT 1;

-- 3 Auditoría DELETE sobre Clientes
DELIMITER $$
CREATE TRIGGER trg_auditoria_delete_clientes
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (usuario, fecha_hora, accion, tabla_afectada, detalle)
    VALUES (
        CURRENT_USER(), NOW(), 'DELETE', 'clientes',
        CONCAT('Cliente eliminado: id=', OLD.id_cliente,
               ', cedula=', OLD.cedula,
               ', nombre=', OLD.nombre, ' ', OLD.apellido,
               ', telefono=', COALESCE(OLD.telefono, 'N/A'),
               ', correo=', COALESCE(OLD.correo, 'N/A'),
               ', provincia=', COALESCE(OLD.provincia, 'N/A'),
               ', fecha_nacimiento=', COALESCE(OLD.fecha_nacimiento, 'N/A'))
    );
END $$
DELIMITER ;

-- Ejemplo 3
DELETE FROM clientes WHERE cedula = '1799887766';

SELECT * FROM auditoria WHERE tabla_afectada = 'clientes' AND accion = 'DELETE' ORDER BY id_auditoria DESC LIMIT 1;

-- 4 Descontar Stock por Venta
DELIMITER $$
CREATE TRIGGER trg_descontar_stock_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT stock_actual INTO v_stock FROM productos WHERE id_producto = NEW.id_producto FOR UPDATE;
    IF v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para completar la venta';
    END IF;

    UPDATE productos SET stock_actual = stock_actual - NEW.cantidad WHERE id_producto = NEW.id_producto;

    INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento)
    VALUES (NEW.id_producto, 'Salida', NEW.cantidad, NOW());
END $$
DELIMITER ;

-- Ejemplo 4 
SELECT stock_actual FROM productos WHERE id_producto = 17; 
INSERT INTO detalle_venta (cantidad, precio_aplicado, id_venta, id_producto) VALUES (2, 48.0, 1, 17);
SELECT stock_actual FROM productos WHERE id_producto = 17;

-- 5 Incrementar Stock por Devolución
DELIMITER $$
CREATE TRIGGER trg_incrementar_stock_devolucion
AFTER INSERT ON devoluciones
FOR EACH ROW
BEGIN
    UPDATE productos SET stock_actual = stock_actual + NEW.cantidad WHERE id_producto = NEW.id_producto;

    INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento)
    VALUES (NEW.id_producto, 'Entrada', NEW.cantidad, NOW());
END $$
DELIMITER ;

-- Ejemplo 5
SELECT stock_actual FROM productos WHERE id_producto = 3;
INSERT INTO devoluciones (cantidad, motivo, fecha_devolucion, id_venta, id_producto) VALUES (1, 'Prueba de trigger', CURDATE(), 11, 3);
SELECT stock_actual FROM productos WHERE id_producto = 3;

-- 6 Control de Stock Negativo
DELIMITER $$
CREATE TRIGGER trg_control_stock_negativo
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock_actual < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operacion invalida: el stock no puede quedar en negativo';
    END IF;
END $$
DELIMITER ;

-- Ejemplo 6
UPDATE productos SET stock_actual = 5 WHERE id_producto = 1;

-- 7 Registro de Cambio de Precio
DELIMITER $$
CREATE TRIGGER trg_registro_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio_unitario <> OLD.precio_unitario THEN
        INSERT INTO historial_precios (id_producto, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (OLD.id_producto, OLD.precio_unitario, NEW.precio_unitario, NOW());
    END IF;
END $$
DELIMITER ;

-- Ejemplo 7
UPDATE productos SET precio_unitario = 92.50 WHERE id_producto = 1;
SELECT * FROM historial_precios WHERE id_producto = 1 ORDER BY id_historial DESC LIMIT 1;

-- 8 Registro de Acceso
DELIMITER $$
CREATE TRIGGER trg_registro_acceso
AFTER INSERT ON auditoria
FOR EACH ROW
BEGIN
    IF NEW.accion <> 'ACCESO' THEN
        INSERT INTO registro_accesos (usuario, fecha_hora, tabla_afectada, detalle)
        VALUES (
            NEW.usuario, NOW(), NEW.tabla_afectada,
            CONCAT('Acceso registrado a partir del evento id_auditoria=', NEW.id_auditoria)
        );
    END IF;
END $$
DELIMITER ;

-- Ejemplo 8
INSERT INTO auditoria (usuario, fecha_hora, accion, tabla_afectada, detalle)
VALUES ('usuario_admin', NOW(), 'INSERT', 'promociones', 'Prueba manual de auditoria');

SELECT * FROM registro_accesos ORDER BY id_acceso DESC LIMIT 1;

-- =========================================================
-- TRANSACCIONES
-- =========================================================
-- Venta Completa
START TRANSACTION;
INSERT INTO ventas (id_cliente, id_empleado, id_promocion, fecha, tipo_venta, subtotal, descuento, total_venta)
VALUES (2, 5, 2, CURDATE(), 'Minorista', 100, 15, 85);
SET @id_venta = LAST_INSERT_ID();
INSERT INTO detalle_venta (cantidad, precio_aplicado, id_venta, id_producto)
VALUES (2, 50, @id_venta, 9);
COMMIT;

-- Devolucion Completa
START TRANSACTION;
INSERT INTO devoluciones (cantidad, motivo, fecha_devolucion, id_venta, id_producto)
VALUES (1, 'Talla incorrecta', CURDATE(), 5, 3);
COMMIT;

-- Compra a Proveedor
START TRANSACTION;
INSERT INTO compras (id_proveedor, fecha_compra, total_compra)
VALUES (6, CURDATE(), 500);
SET @id_compra = LAST_INSERT_ID();
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_unitario)
VALUES (@id_compra, 3, 10, 50);
UPDATE productos SET stock_actual = stock_actual + 10 WHERE id_producto = 3;
INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento)
VALUES (3, 'Entrada', 10, NOW());
COMMIT;

-- Actualizacion Masiva de Inventario
START TRANSACTION;
UPDATE productos SET stock_actual = stock_actual + 5 WHERE id_categoria = 1;
INSERT INTO inventario (id_producto, tipo_movimiento, cantidad, fecha_movimiento)
SELECT id_producto, 'Entrada', 5, NOW() FROM productos WHERE id_categoria = 1;
COMMIT;
-- =========================================================
-- USUARIOS, ROLES Y PRIVILEGIOS
-- =========================================================
-- Administrador
DROP USER IF EXISTS 'usuario_admin'@'localhost';
CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON calzado_db.* TO 'usuario_admin'@'localhost';

-- Gerente
DROP USER IF EXISTS 'usuario_gerente'@'localhost';
CREATE USER 'usuario_gerente'@'localhost' IDENTIFIED BY 'gerente123';
GRANT SELECT ON calzado_db.ventas TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.detalle_venta TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.clientes TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.productos TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_clientes_frecuentes TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_ventas_consolidadas TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_productos_bajo_stock TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_promociones_aplicadas TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_devoluciones TO 'usuario_gerente'@'localhost';
GRANT SELECT ON calzado_db.vw_desempeno_vendedores TO 'usuario_gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE calzado_db.sp_calcular_ventas_mensuales TO 'usuario_gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE calzado_db.sp_productos_bajo_stock TO 'usuario_gerente'@'localhost';
GRANT EXECUTE ON PROCEDURE calzado_db.sp_clientes_frecuentes TO 'usuario_gerente'@'localhost';
GRANT EXECUTE ON FUNCTION calzado_db.fn_calcular_comision TO 'usuario_gerente'@'localhost';

-- Cajero
DROP USER IF EXISTS 'usuario_cajero'@'localhost';
CREATE USER 'usuario_cajero'@'localhost' IDENTIFIED BY 'cajero123';
GRANT SELECT ON calzado_db.clientes TO 'usuario_cajero'@'localhost';
GRANT SELECT ON calzado_db.productos TO 'usuario_cajero'@'localhost';
GRANT INSERT ON calzado_db.ventas TO 'usuario_cajero'@'localhost';
GRANT INSERT ON calzado_db.detalle_venta TO 'usuario_cajero'@'localhost';
GRANT EXECUTE ON PROCEDURE calzado_db.sp_registrar_venta TO 'usuario_cajero'@'localhost';

-- Vendedor
DROP USER IF EXISTS 'usuario_vendedor'@'localhost';
CREATE USER 'usuario_vendedor'@'localhost' IDENTIFIED BY 'vendedor123';
GRANT SELECT ON calzado_db.clientes TO 'usuario_vendedor'@'localhost';
GRANT SELECT ON calzado_db.productos TO 'usuario_vendedor'@'localhost';
GRANT SELECT ON calzado_db.vw_clientes_frecuentes TO 'usuario_vendedor'@'localhost';
GRANT SELECT ON calzado_db.vw_productos_bajo_stock TO 'usuario_vendedor'@'localhost';
GRANT SELECT ON calzado_db.vw_desempeno_vendedores TO 'usuario_vendedor'@'localhost';
GRANT INSERT ON calzado_db.ventas TO 'usuario_vendedor'@'localhost';
GRANT EXECUTE ON PROCEDURE calzado_db.sp_registrar_venta TO 'usuario_vendedor'@'localhost';

-- Auditor
DROP USER IF EXISTS 'usuario_auditor'@'localhost';
CREATE USER 'usuario_auditor'@'localhost' IDENTIFIED BY 'auditor123';
GRANT SELECT ON calzado_db.auditoria TO 'usuario_auditor'@'localhost';
GRANT SELECT ON calzado_db.historial_precios TO 'usuario_auditor'@'localhost';
GRANT SELECT ON calzado_db.vw_ventas_consolidadas TO 'usuario_auditor'@'localhost';
GRANT SELECT ON calzado_db.vw_devoluciones TO 'usuario_auditor'@'localhost';
GRANT SELECT ON calzado_db.vw_desempeno_vendedores TO 'usuario_auditor'@'localhost';

-- =========================================================
-- RESPALDO Y RECUPERACIÓN
-- =========================================================
-- Tabla de registro de respaldos (Historial)
CREATE TABLE IF NOT EXISTS respaldo (
    id_backup INT AUTO_INCREMENT PRIMARY KEY,
    nombre_backup VARCHAR(100) NOT NULL,
    fecha_backup DATE NOT NULL DEFAULT (CURRENT_DATE),
    hora_backup TIME NOT NULL DEFAULT (CURRENT_TIME),
    usuario_responsable VARCHAR(50) NOT NULL,
    tipo_respaldo VARCHAR(20) NOT NULL CHECK (tipo_respaldo IN ('Inicial', 'Intermedio', 'Final'))
) ENGINE=InnoDB;

-- Inserción de prueba en el historial
INSERT INTO respaldo (nombre_backup, usuario_responsable, tipo_respaldo) VALUES
    ('backup_calzado_inicial.sql', CURRENT_USER(), 'Inicial'),
    ('backup_calzado_intermedio.sql', CURRENT_USER(), 'Intermedio'),
    ('backup_calzado_final.sql', CURRENT_USER(), 'Final');

-- Verificación del historial
SELECT * FROM respaldo;

-- =========================================================
-- COMANDOS REALES PARA LA TERMINAL (CMD / PowerShell)
-- =========================================================

-- Backup
-- mysqldump -u root -p proyecto_calzado > backup_calzado_final.sql

-- Recovery
-- mysql -u root -p proyecto_calzado < backup_calzado_final.sql

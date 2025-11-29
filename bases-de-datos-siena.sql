CREATE DATABASE siena;
 use siena;

 -- =============================================
-- Base de Datos: Siena Shopping
-- =============================================

-- =============================================
-- Tablas de Catálogo y Soporte
-- =============================================

CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE Tallas (
    id_talla INT PRIMARY KEY AUTO_INCREMENT,
    nombre_talla VARCHAR(10) NOT NULL UNIQUE -- Ej: 'XS', 'S', 'M', 'L', 'XL'
);

CREATE TABLE Colores (
    id_color INT PRIMARY KEY AUTO_INCREMENT,
    nombre_color VARCHAR(30) NOT NULL UNIQUE -- Ej: 'Rojo', 'Azul Marino', 'Negro'
);

CREATE TABLE Metodos_Pago (
    id_metodo_pago INT PRIMARY KEY AUTO_INCREMENT,
    nombre_metodo VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Efectivo', 'Tarjeta Crédito', 'Transferencia'
);

-- =============================================
-- Tablas de Entidades Principales
-- =============================================

CREATE TABLE Proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proveedor VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    direccion VARCHAR(255)
);

CREATE TABLE Productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_venta DECIMAL(10, 2) NOT NULL,
    precio_costo DECIMAL(10, 2), -- Para calcular ganancias
    codigo_barras VARCHAR(50) UNIQUE,
    id_categoria INT,
    id_proveedor INT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Inventario (
    id_inventario INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_talla INT NOT NULL,
    id_color INT NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5, -- Umbral para alerta
    UNIQUE (id_producto, id_talla, id_color), -- Evita duplicados para la misma combinación
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_talla) REFERENCES Tallas(id_talla) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_color) REFERENCES Colores(id_color) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Empleados (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    documento VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL, -- ¡Debe estar hasheada!
    rol ENUM('admin', 'vendedor') NOT NULL DEFAULT 'vendedor',
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    preferencias VARCHAR(255) -- Campo para notas o preferencias
);

-- =============================================
-- Tablas Transaccionales
-- =============================================

CREATE TABLE Ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    id_empleado INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_venta DECIMAL(10, 2) NOT NULL,
    descuento_total DECIMAL(10, 2) DEFAULT 0.00,
    id_metodo_pago INT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Detalle_Venta (
    id_detalle_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_venta INT NOT NULL,
    id_inventario INT NOT NULL, -- Se relaciona con la variante exacta del producto
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL, -- Precio al momento de la venta
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_inventario) REFERENCES Inventario(id_inventario) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================
-- Tabla de Interacción y Fidelización (Reseñas)
-- =============================================

CREATE TABLE Resenas (
    id_resena INT PRIMARY KEY AUTO_INCREMENT,
    id_detalle_venta INT NOT NULL UNIQUE, -- Clave para asegurar que solo se reseñe lo comprado y una sola vez
    calificacion TINYINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5), -- Calificación de 1 a 5 estrellas
    comentario TEXT,
    fecha_resena TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aprobada BOOLEAN NOT NULL DEFAULT TRUE, -- Para moderación de contenido
    FOREIGN KEY (id_detalle_venta) REFERENCES Detalle_Venta(id_detalle_venta) ON DELETE CASCADE ON UPDATE RESTRICT
);

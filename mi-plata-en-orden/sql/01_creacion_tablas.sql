-- ============================================================
-- Mi plata en orden · Modelo físico
-- Script de creación de tablas (MySQL 8.0.16 o superior)
-- ============================================================

DROP DATABASE IF EXISTS mi_plata_en_orden;
CREATE DATABASE mi_plata_en_orden CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE mi_plata_en_orden;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- Tablas sin llaves foráneas (se crean primero)
-- ------------------------------------------------------------

CREATE TABLE ciudad (
  id_ciudad   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id_ciudad),
  CONSTRAINT uq_ciudad_nombre UNIQUE (nombre)
);

CREATE TABLE pais (
  codigo_pais CHAR(2)     NOT NULL,
  nombre      VARCHAR(60) NOT NULL,
  PRIMARY KEY (codigo_pais),
  CONSTRAINT uq_pais_nombre UNIQUE (nombre)
);

CREATE TABLE tipo_entidad (
  id_tipo_entidad INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(40)  NOT NULL,
  PRIMARY KEY (id_tipo_entidad),
  CONSTRAINT uq_tipo_entidad_nombre UNIQUE (nombre)
);

CREATE TABLE moneda (
  codigo_moneda CHAR(3)     NOT NULL,
  nombre        VARCHAR(40) NOT NULL,
  PRIMARY KEY (codigo_moneda)
);

-- RN_005: cada tipo de cuenta es de clase activo o pasivo
CREATE TABLE tipo_cuenta (
  id_tipo_cuenta INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(40)  NOT NULL,
  clase          VARCHAR(10)  NOT NULL,
  PRIMARY KEY (id_tipo_cuenta),
  CONSTRAINT uq_tipo_cuenta_nombre UNIQUE (nombre),
  CONSTRAINT ck_tipo_cuenta_clase CHECK (clase IN ('activo', 'pasivo'))
);

-- RN_020: los tipos de tercero son comercio, cliente, empleador u otro
CREATE TABLE tipo_tercero (
  id_tipo_tercero INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(40)  NOT NULL,
  PRIMARY KEY (id_tipo_tercero),
  CONSTRAINT uq_tipo_tercero_nombre UNIQUE (nombre)
);

-- ------------------------------------------------------------
-- Personas, entidades financieras y tasas de cambio
-- ------------------------------------------------------------

-- RN_001: el correo de cada persona es único
CREATE TABLE persona (
  id_persona         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_ciudad          INT UNSIGNED  NOT NULL,
  nombres            VARCHAR(60)   NOT NULL,
  apellidos          VARCHAR(60)   NOT NULL,
  correo             VARCHAR(100)  NOT NULL,
  celular            VARCHAR(15)   NULL,
  fecha_registro     DATE          NOT NULL DEFAULT (CURRENT_DATE),
  tope_gasto_hormiga DECIMAL(12,2) NULL,
  PRIMARY KEY (id_persona),
  CONSTRAINT uq_persona_correo UNIQUE (correo),
  CONSTRAINT ck_persona_tope CHECK (tope_gasto_hormiga > 0),
  CONSTRAINT fk_persona_ciudad FOREIGN KEY (id_ciudad)
    REFERENCES ciudad (id_ciudad)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE entidad_financiera (
  id_entidad      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_tipo_entidad INT UNSIGNED NOT NULL,
  codigo_pais     CHAR(2)      NOT NULL,
  nombre          VARCHAR(80)  NOT NULL,
  PRIMARY KEY (id_entidad),
  CONSTRAINT uq_entidad_nombre_pais UNIQUE (nombre, codigo_pais),
  CONSTRAINT fk_entidad_tipo FOREIGN KEY (id_tipo_entidad)
    REFERENCES tipo_entidad (id_tipo_entidad)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_entidad_pais FOREIGN KEY (codigo_pais)
    REFERENCES pais (codigo_pais)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RN_019: como máximo una tasa de cambio por moneda y fecha (llave compuesta)
CREATE TABLE tasa_cambio (
  codigo_moneda  CHAR(3)       NOT NULL,
  fecha          DATE          NOT NULL,
  valor_en_pesos DECIMAL(14,4) NOT NULL,
  PRIMARY KEY (codigo_moneda, fecha),
  CONSTRAINT ck_tasa_valor CHECK (valor_en_pesos > 0),
  CONSTRAINT fk_tasa_moneda FOREIGN KEY (codigo_moneda)
    REFERENCES moneda (codigo_moneda)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Cuentas
-- ------------------------------------------------------------

-- RN_002 y RN_003: cada cuenta tiene una persona y una moneda (NOT NULL)
-- RN_004: la entidad financiera es opcional, para el efectivo (NULL)
-- RN_006: el estado es activa o cerrada
-- RN_007: día de corte y día de pago entre 1 y 31; cupo mayor que cero
CREATE TABLE cuenta (
  id_cuenta           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_persona          INT UNSIGNED     NOT NULL,
  id_tipo_cuenta      INT UNSIGNED     NOT NULL,
  id_entidad          INT UNSIGNED     NULL,
  codigo_moneda       CHAR(3)          NOT NULL,
  nombre              VARCHAR(60)      NOT NULL,
  ultimos_cuatro      CHAR(4)          NULL,
  saldo_inicial       DECIMAL(14,2)    NOT NULL DEFAULT 0,
  fecha_saldo_inicial DATE             NOT NULL,
  estado              VARCHAR(10)      NOT NULL DEFAULT 'activa',
  cupo                DECIMAL(14,2)    NULL,
  dia_corte           TINYINT UNSIGNED NULL,
  dia_pago            TINYINT UNSIGNED NULL,
  PRIMARY KEY (id_cuenta),
  CONSTRAINT uq_cuenta_persona_nombre UNIQUE (id_persona, nombre),
  CONSTRAINT ck_cuenta_estado CHECK (estado IN ('activa', 'cerrada')),
  CONSTRAINT ck_cuenta_cupo CHECK (cupo > 0),
  CONSTRAINT ck_cuenta_dia_corte CHECK (dia_corte BETWEEN 1 AND 31),
  CONSTRAINT ck_cuenta_dia_pago CHECK (dia_pago BETWEEN 1 AND 31),
  CONSTRAINT fk_cuenta_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cuenta_tipo FOREIGN KEY (id_tipo_cuenta)
    REFERENCES tipo_cuenta (id_tipo_cuenta)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cuenta_entidad FOREIGN KEY (id_entidad)
    REFERENCES entidad_financiera (id_entidad)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_cuenta_moneda FOREIGN KEY (codigo_moneda)
    REFERENCES moneda (codigo_moneda)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Categorías, terceros, etiquetas y pagos fijos
-- ------------------------------------------------------------

-- RN_008: cada categoría es de ingreso o de gasto
-- id_categoria_padre: relación recursiva (subcategorías)
-- id_persona vacío: categoría del sistema
CREATE TABLE categoria (
  id_categoria       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_categoria_padre INT UNSIGNED NULL,
  id_persona         INT UNSIGNED NULL,
  nombre             VARCHAR(60)  NOT NULL,
  naturaleza         VARCHAR(7)   NOT NULL,
  PRIMARY KEY (id_categoria),
  CONSTRAINT ck_categoria_naturaleza CHECK (naturaleza IN ('ingreso', 'gasto')),
  CONSTRAINT fk_categoria_padre FOREIGN KEY (id_categoria_padre)
    REFERENCES categoria (id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_categoria_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE tercero (
  id_tercero      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_persona      INT UNSIGNED NOT NULL,
  id_tipo_tercero INT UNSIGNED NOT NULL,
  nombre          VARCHAR(80)  NOT NULL,
  identificacion  VARCHAR(20)  NULL,
  PRIMARY KEY (id_tercero),
  CONSTRAINT fk_tercero_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tercero_tipo FOREIGN KEY (id_tipo_tercero)
    REFERENCES tipo_tercero (id_tipo_tercero)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE etiqueta (
  id_etiqueta INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_persona  INT UNSIGNED NOT NULL,
  nombre      VARCHAR(40)  NOT NULL,
  PRIMARY KEY (id_etiqueta),
  CONSTRAINT uq_etiqueta_persona_nombre UNIQUE (id_persona, nombre),
  CONSTRAINT fk_etiqueta_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RN_016: frecuencia mensual o anual; estado activo o inactivo
CREATE TABLE pago_fijo (
  id_pago_fijo     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_cuenta        INT UNSIGNED     NOT NULL,
  id_categoria     INT UNSIGNED     NOT NULL,
  nombre           VARCHAR(60)      NOT NULL,
  valor_aproximado DECIMAL(14,2)    NOT NULL,
  dia_pago         TINYINT UNSIGNED NOT NULL,
  frecuencia       VARCHAR(10)      NOT NULL,
  estado           VARCHAR(10)      NOT NULL DEFAULT 'activo',
  PRIMARY KEY (id_pago_fijo),
  CONSTRAINT ck_pago_valor CHECK (valor_aproximado > 0),
  CONSTRAINT ck_pago_dia CHECK (dia_pago BETWEEN 1 AND 31),
  CONSTRAINT ck_pago_frecuencia CHECK (frecuencia IN ('mensual', 'anual')),
  CONSTRAINT ck_pago_estado CHECK (estado IN ('activo', 'inactivo')),
  CONSTRAINT fk_pago_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta (id_cuenta)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pago_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Movimientos, cuotas y etiquetas de los movimientos
-- ------------------------------------------------------------

-- RN_008: cada movimiento tiene una sola categoría (NOT NULL)
-- RN_009: el valor es mayor que cero
-- RN_014: el número de cuotas es mayor o igual a uno
CREATE TABLE movimiento (
  id_movimiento    INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  id_cuenta        INT UNSIGNED     NOT NULL,
  id_categoria     INT UNSIGNED     NOT NULL,
  id_tercero       INT UNSIGNED     NULL,
  id_pago_fijo     INT UNSIGNED     NULL,
  fecha_ocurrencia DATE             NOT NULL,
  fecha_registro   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valor            DECIMAL(14,2)    NOT NULL,
  descripcion      VARCHAR(150)     NULL,
  numero_cuotas    TINYINT UNSIGNED NULL,
  tasa_interes     DECIMAL(5,2)     NULL,
  PRIMARY KEY (id_movimiento),
  CONSTRAINT ck_movimiento_valor CHECK (valor > 0),
  CONSTRAINT ck_movimiento_cuotas CHECK (numero_cuotas >= 1),
  CONSTRAINT ck_movimiento_tasa CHECK (tasa_interes >= 0),
  CONSTRAINT fk_movimiento_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta (id_cuenta)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_tercero FOREIGN KEY (id_tercero)
    REFERENCES tercero (id_tercero)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_pago FOREIGN KEY (id_pago_fijo)
    REFERENCES pago_fijo (id_pago_fijo)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- Concepto débil: llave compuesta (id_movimiento, numero)
-- RN_015: el estado de una cuota es pagada o pendiente
CREATE TABLE cuota (
  id_movimiento         INT UNSIGNED     NOT NULL,
  numero                TINYINT UNSIGNED NOT NULL,
  mes                   DATE             NOT NULL,
  capital               DECIMAL(14,2)    NOT NULL,
  intereses_proyectados DECIMAL(14,2)    NOT NULL DEFAULT 0,
  estado                VARCHAR(10)      NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (id_movimiento, numero),
  CONSTRAINT ck_cuota_numero CHECK (numero >= 1),
  CONSTRAINT ck_cuota_mes CHECK (DAY(mes) = 1),
  CONSTRAINT ck_cuota_capital CHECK (capital > 0),
  CONSTRAINT ck_cuota_intereses CHECK (intereses_proyectados >= 0),
  CONSTRAINT ck_cuota_estado CHECK (estado IN ('pagada', 'pendiente')),
  CONSTRAINT fk_cuota_movimiento FOREIGN KEY (id_movimiento)
    REFERENCES movimiento (id_movimiento)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla intermedia de la relación de muchos a muchos
CREATE TABLE movimiento_etiqueta (
  id_movimiento INT UNSIGNED NOT NULL,
  id_etiqueta   INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_movimiento, id_etiqueta),
  CONSTRAINT fk_me_movimiento FOREIGN KEY (id_movimiento)
    REFERENCES movimiento (id_movimiento)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_me_etiqueta FOREIGN KEY (id_etiqueta)
    REFERENCES etiqueta (id_etiqueta)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Traslados entre cuentas
-- ------------------------------------------------------------

-- RN_011: origen y destino distintos; valores mayores que cero
-- (que ambas cuentas sean de la misma persona se valida en la aplicación
--  o con un disparador, porque compara datos de otra tabla)
-- En MySQL, una columna que se usa en un CHECK no puede tener una llave foránea
-- con acción en cascada; por eso estas dos llaves usan RESTRICT también al actualizar.
CREATE TABLE traslado (
  id_traslado       INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_cuenta_origen  INT UNSIGNED  NOT NULL,
  id_cuenta_destino INT UNSIGNED  NOT NULL,
  fecha             DATE          NOT NULL,
  valor_sale        DECIMAL(14,2) NOT NULL,
  valor_llega       DECIMAL(14,2) NOT NULL,
  PRIMARY KEY (id_traslado),
  CONSTRAINT ck_traslado_cuentas CHECK (id_cuenta_origen <> id_cuenta_destino),
  CONSTRAINT ck_traslado_sale CHECK (valor_sale > 0),
  CONSTRAINT ck_traslado_llega CHECK (valor_llega > 0),
  CONSTRAINT fk_traslado_origen FOREIGN KEY (id_cuenta_origen)
    REFERENCES cuenta (id_cuenta)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_traslado_destino FOREIGN KEY (id_cuenta_destino)
    REFERENCES cuenta (id_cuenta)
    ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- ------------------------------------------------------------
-- Presupuestos
-- ------------------------------------------------------------

-- RN_012: como máximo un presupuesto por persona y mes
CREATE TABLE presupuesto (
  id_presupuesto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_persona     INT UNSIGNED NOT NULL,
  mes            DATE         NOT NULL,
  PRIMARY KEY (id_presupuesto),
  CONSTRAINT uq_presupuesto_persona_mes UNIQUE (id_persona, mes),
  CONSTRAINT ck_presupuesto_mes CHECK (DAY(mes) = 1),
  CONSTRAINT fk_presupuesto_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RN_012: cada categoría aparece una sola vez en un presupuesto (llave compuesta)
-- RN_013: porcentaje de alerta entre 1 y 100, con 80 por omisión
CREATE TABLE presupuesto_categoria (
  id_presupuesto    INT UNSIGNED     NOT NULL,
  id_categoria      INT UNSIGNED     NOT NULL,
  valor_planeado    DECIMAL(14,2)    NOT NULL,
  porcentaje_alerta TINYINT UNSIGNED NOT NULL DEFAULT 80,
  PRIMARY KEY (id_presupuesto, id_categoria),
  CONSTRAINT ck_pc_valor CHECK (valor_planeado > 0),
  CONSTRAINT ck_pc_alerta CHECK (porcentaje_alerta BETWEEN 1 AND 100),
  CONSTRAINT fk_pc_presupuesto FOREIGN KEY (id_presupuesto)
    REFERENCES presupuesto (id_presupuesto)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pc_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- Metas de ahorro y aportes
-- ------------------------------------------------------------

-- RN_017: valor necesario mayor que cero; estado activa, cumplida o cancelada
CREATE TABLE meta_ahorro (
  id_meta         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_persona      INT UNSIGNED  NOT NULL,
  nombre          VARCHAR(60)   NOT NULL,
  valor_necesario DECIMAL(14,2) NOT NULL,
  fecha_objetivo  DATE          NOT NULL,
  estado          VARCHAR(10)   NOT NULL DEFAULT 'activa',
  PRIMARY KEY (id_meta),
  CONSTRAINT ck_meta_valor CHECK (valor_necesario > 0),
  CONSTRAINT ck_meta_estado CHECK (estado IN ('activa', 'cumplida', 'cancelada')),
  CONSTRAINT fk_meta_persona FOREIGN KEY (id_persona)
    REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RN_018: cada aporte corresponde a una meta; valor mayor que cero; tipo aporte o retiro
CREATE TABLE aporte (
  id_aporte INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_meta   INT UNSIGNED  NOT NULL,
  id_cuenta INT UNSIGNED  NOT NULL,
  fecha     DATE          NOT NULL,
  valor     DECIMAL(14,2) NOT NULL,
  tipo      VARCHAR(7)    NOT NULL,
  PRIMARY KEY (id_aporte),
  CONSTRAINT ck_aporte_valor CHECK (valor > 0),
  CONSTRAINT ck_aporte_tipo CHECK (tipo IN ('aporte', 'retiro')),
  CONSTRAINT fk_aporte_meta FOREIGN KEY (id_meta)
    REFERENCES meta_ahorro (id_meta)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_aporte_cuenta FOREIGN KEY (id_cuenta)
    REFERENCES cuenta (id_cuenta)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

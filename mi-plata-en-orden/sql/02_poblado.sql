-- ============================================================
-- Mi plata en orden · Poblado de las tablas
-- Las tablas se pueblan en el mismo orden en que se crearon:
-- primero las que no tienen llaves foráneas.
-- ============================================================

USE mi_plata_en_orden;
SET NAMES utf8mb4;

INSERT INTO ciudad (nombre) VALUES
  ('Bogotá'), ('Medellín'), ('Cali'), ('Barranquilla');

INSERT INTO pais (codigo_pais, nombre) VALUES
  ('CO', 'Colombia'), ('US', 'Estados Unidos');

INSERT INTO tipo_entidad (nombre) VALUES
  ('banco'), ('cooperativa'), ('billetera digital'), ('comisionista de bolsa');

INSERT INTO moneda (codigo_moneda, nombre) VALUES
  ('COP', 'Peso colombiano'), ('USD', 'Dólar estadounidense');

-- RN_005: los cinco primeros tipos son de clase activo y los dos últimos, de clase pasivo
INSERT INTO tipo_cuenta (nombre, clase) VALUES
  ('ahorros', 'activo'),
  ('corriente', 'activo'),
  ('billetera digital', 'activo'),
  ('inversión', 'activo'),
  ('efectivo', 'activo'),
  ('tarjeta de crédito', 'pasivo'),
  ('crédito', 'pasivo');

-- RN_020
INSERT INTO tipo_tercero (nombre) VALUES
  ('comercio'), ('cliente'), ('empleador'), ('otro');

INSERT INTO persona (id_ciudad, nombres, apellidos, correo, celular, fecha_registro, tope_gasto_hormiga) VALUES
  (1, 'Sofía', 'Ramírez Gómez', 'sofia.r@correo.com', '3001234567', '2026-08-01', 15000),
  (2, 'Andrés Felipe', 'Torres Díaz', 'aftorres@correo.com', '3152221188', '2026-09-12', NULL),
  (3, 'Marta Lucía', 'Rojas Peña', 'mlrojas@correo.com', NULL, '2026-10-05', 10000);

INSERT INTO entidad_financiera (id_tipo_entidad, codigo_pais, nombre) VALUES
  (1, 'CO', 'Banco Andino'),
  (2, 'CO', 'Cooperativa Futuro'),
  (3, 'CO', 'Billetera Ágil'),
  (1, 'US', 'Northern Bank');

INSERT INTO tasa_cambio (codigo_moneda, fecha, valor_en_pesos) VALUES
  ('USD', '2026-10-01', 3900.5000),
  ('USD', '2026-10-15', 3925.1000),
  ('USD', '2026-11-01', 3880.0000);

-- La cuenta de efectivo no tiene entidad financiera (RN_004): id_entidad queda en NULL.
-- El cupo, el día de corte y el día de pago solo se registran en la tarjeta de crédito (RN_007).
INSERT INTO cuenta (id_persona, id_tipo_cuenta, id_entidad, codigo_moneda, nombre, ultimos_cuatro,
                    saldo_inicial, fecha_saldo_inicial, estado, cupo, dia_corte, dia_pago) VALUES
  (1, 1, 1, 'COP', 'Ahorros de la casa', '4521', 2500000, '2026-08-01', 'activa', NULL, NULL, NULL),
  (1, 5, NULL, 'COP', 'Efectivo', NULL, 150000, '2026-08-01', 'activa', NULL, NULL, NULL),
  (1, 6, 1, 'COP', 'Tarjeta del supermercado', '7788', 0, '2026-08-01', 'activa', 5000000, 25, 10),
  (1, 1, 2, 'COP', 'Ahorro para el viaje', '0912', 0, '2026-08-01', 'activa', NULL, NULL, NULL),
  (1, 3, 3, 'COP', 'Billetera', NULL, 80000, '2026-08-01', 'activa', NULL, NULL, NULL),
  (2, 1, 1, 'COP', 'Cuenta de nómina', '3307', 1200000, '2026-09-12', 'activa', NULL, NULL, NULL),
  (2, 1, 4, 'USD', 'Ahorros en dólares', '6650', 500, '2026-09-12', 'activa', NULL, NULL, NULL),
  (3, 5, NULL, 'COP', 'Efectivo', NULL, 60000, '2026-10-05', 'activa', NULL, NULL, NULL);

-- Primero las categorías principales y después las subcategorías, que las referencian.
-- id_persona en NULL: categorías del sistema.
INSERT INTO categoria (id_categoria_padre, id_persona, nombre, naturaleza) VALUES
  (NULL, NULL, 'Salario', 'ingreso'),
  (NULL, NULL, 'Honorarios', 'ingreso'),
  (NULL, NULL, 'Vivienda', 'gasto'),
  (NULL, NULL, 'Alimentación', 'gasto'),
  (4, NULL, 'Mercado', 'gasto'),
  (4, NULL, 'Restaurantes', 'gasto'),
  (4, NULL, 'Cafetería', 'gasto'),
  (NULL, NULL, 'Transporte', 'gasto'),
  (3, NULL, 'Servicios públicos', 'gasto'),
  (NULL, NULL, 'Entretenimiento', 'gasto'),
  (NULL, NULL, 'Hogar', 'gasto'),
  (NULL, 1, 'Mascotas', 'gasto'),
  (NULL, 2, 'Venta de artesanías', 'ingreso');

INSERT INTO tercero (id_persona, id_tipo_tercero, nombre, identificacion) VALUES
  (1, 1, 'Supermercado La Canasta', '900123456'),
  (1, 3, 'Datos Claros S. A. S.', '901555333'),
  (1, 4, 'Inmobiliaria Techo', NULL),
  (1, 1, 'Aerolínea Cóndor', '860000111'),
  (1, 1, 'Hotel Mar Azul', NULL),
  (1, 1, 'Almacén Hogar Total', '900777888'),
  (2, 2, 'Tienda Raíces', NULL);

INSERT INTO etiqueta (id_persona, nombre) VALUES
  (1, 'viaje Cartagena'), (1, 'vacaciones'), (1, 'familia');

INSERT INTO pago_fijo (id_cuenta, id_categoria, nombre, valor_aproximado, dia_pago, frecuencia, estado) VALUES
  (1, 3, 'Arriendo', 1200000, 5, 'mensual', 'activo'),
  (1, 9, 'Internet', 95000, 15, 'mensual', 'activo'),
  (1, 8, 'Seguro del carro', 1100000, 20, 'anual', 'activo'),
  (3, 10, 'Gimnasio', 120000, 1, 'mensual', 'inactivo');

INSERT INTO movimiento (id_cuenta, id_categoria, id_tercero, id_pago_fijo, fecha_ocurrencia,
                        fecha_registro, valor, descripcion, numero_cuotas, tasa_interes) VALUES
  (1, 1, 2, NULL, '2026-09-30', '2026-09-30 18:10:00', 4800000, 'Salario de septiembre', NULL, NULL),
  (1, 3, 3, 1, '2026-10-05', '2026-10-05 09:00:00', 1200000, 'Arriendo de octubre', NULL, NULL),
  (1, 6, NULL, NULL, '2026-10-03', '2026-10-03 21:15:00', 18000, 'Domicilio', NULL, NULL),
  (2, 7, NULL, NULL, '2026-10-03', '2026-10-04 08:00:00', 4500, 'Tinto', NULL, NULL),
  (1, 5, 1, NULL, '2026-10-06', '2026-10-06 19:30:00', 320000, 'Mercado', NULL, NULL),
  (1, 9, NULL, 2, '2026-10-15', '2026-10-15 07:45:00', 95000, 'Internet de octubre', NULL, NULL),
  (3, 8, 4, NULL, '2026-10-12', '2026-10-12 12:00:00', 640000, 'Tiquetes aéreos', 1, 0),
  (3, 10, 5, NULL, '2026-10-12', '2026-10-12 12:20:00', 900000, 'Hotel', 1, 0),
  (3, 11, 6, NULL, '2026-10-20', '2026-10-20 16:40:00', 1800000, 'Nevera', 3, 28.50),
  (2, 7, NULL, NULL, '2026-10-21', '2026-10-21 10:05:00', 3500, 'Empanada', NULL, NULL),
  (5, 12, NULL, NULL, '2026-10-22', '2026-10-22 17:00:00', 85000, 'Concentrado para la perra', NULL, NULL),
  (1, 5, 1, NULL, '2026-11-03', '2026-11-03 19:00:00', 280000, 'Mercado', NULL, NULL),
  (6, 13, 7, NULL, '2026-10-10', '2026-10-10 15:00:00', 450000, 'Venta de mochilas', NULL, NULL),
  (6, 6, NULL, NULL, '2026-10-11', '2026-10-11 13:30:00', 42000, 'Almuerzo', NULL, NULL);

-- Las cuotas referencian movimientos que ya existen (7, 8 y 9)
INSERT INTO cuota (id_movimiento, numero, mes, capital, intereses_proyectados, estado) VALUES
  (7, 1, '2026-11-01', 640000, 0, 'pagada'),
  (8, 1, '2026-11-01', 900000, 0, 'pagada'),
  (9, 1, '2026-11-01', 600000, 37980, 'pagada'),
  (9, 2, '2026-12-01', 600000, 25320, 'pendiente'),
  (9, 3, '2027-01-01', 600000, 12660, 'pendiente');

INSERT INTO movimiento_etiqueta (id_movimiento, id_etiqueta) VALUES
  (7, 1), (7, 2), (8, 1), (8, 2), (8, 3);

INSERT INTO traslado (id_cuenta_origen, id_cuenta_destino, fecha, valor_sale, valor_llega) VALUES
  (1, 4, '2026-10-01', 500000, 500000),
  (1, 3, '2026-11-10', 2177980, 2177980),
  (6, 7, '2026-10-20', 392510, 100);

INSERT INTO presupuesto (id_persona, mes) VALUES
  (1, '2026-10-01'), (1, '2026-11-01'), (2, '2026-10-01');

INSERT INTO presupuesto_categoria (id_presupuesto, id_categoria, valor_planeado, porcentaje_alerta) VALUES
  (1, 3, 1200000, 90),
  (1, 5, 600000, 80),
  (1, 6, 150000, 80),
  (1, 7, 40000, 70),
  (1, 9, 200000, 80),
  (2, 5, 600000, 80),
  (2, 6, 120000, 80),
  (3, 6, 200000, 80);

INSERT INTO meta_ahorro (id_persona, nombre, valor_necesario, fecha_objetivo, estado) VALUES
  (1, 'Viaje a Cartagena', 3000000, '2027-06-30', 'activa'),
  (1, 'Fondo de emergencia', 6000000, '2027-12-31', 'activa'),
  (2, 'Computador', 3500000, '2026-09-30', 'cumplida');

INSERT INTO aporte (id_meta, id_cuenta, fecha, valor, tipo) VALUES
  (1, 4, '2026-08-30', 500000, 'aporte'),
  (1, 4, '2026-09-30', 500000, 'aporte'),
  (1, 4, '2026-10-15', 150000, 'retiro'),
  (1, 4, '2026-10-30', 400000, 'aporte'),
  (2, 1, '2026-10-31', 300000, 'aporte'),
  (3, 6, '2026-09-15', 3500000, 'aporte');

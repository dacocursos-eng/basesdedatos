-- ============================================================
-- Mi plata en orden · Pruebas de las restricciones
-- Cada sentencia se ejecuta por separado sobre la base de datos poblada.
-- Las que violan una restricción deben ser rechazadas por MySQL.
-- ============================================================

USE mi_plata_en_orden;
SET NAMES utf8mb4;

-- RN_009: un movimiento con valor cero
-- Resultado esperado: ERROR 3819, Check constraint 'ck_movimiento_valor' is violated
INSERT INTO movimiento (id_cuenta, id_categoria, fecha_ocurrencia, valor, descripcion)
VALUES (1, 5, '2026-11-05', 0, 'Mercado');

-- RN_001: una persona con un correo que ya existe
-- Resultado esperado: ERROR 1062, Duplicate entry 'sofia.r@correo.com' for key 'persona.uq_persona_correo'
INSERT INTO persona (id_ciudad, nombres, apellidos, correo)
VALUES (1, 'Sofía', 'Ramírez', 'sofia.r@correo.com');

-- RN_007: un día de corte por fuera del rango 1 a 31
-- Resultado esperado: ERROR 3819, Check constraint 'ck_cuenta_dia_corte' is violated
UPDATE cuenta SET dia_corte = 35 WHERE id_cuenta = 3;

-- Integridad referencial: una cuenta de una persona que no existe
-- Resultado esperado: ERROR 1452, Cannot add or update a child row: a foreign key constraint fails
INSERT INTO cuenta (id_persona, id_tipo_cuenta, codigo_moneda, nombre, fecha_saldo_inicial)
VALUES (9, 1, 'COP', 'Cuenta nueva', '2026-11-01');

-- ON DELETE RESTRICT: eliminar una categoría que tiene movimientos
-- Resultado esperado: ERROR 1451, Cannot delete or update a parent row: a foreign key constraint fails
DELETE FROM categoria WHERE id_categoria = 5;

-- RN_011: un traslado con la misma cuenta de origen y de destino
-- Resultado esperado: ERROR 3819, Check constraint 'ck_traslado_cuentas' is violated
INSERT INTO traslado (id_cuenta_origen, id_cuenta_destino, fecha, valor_sale, valor_llega)
VALUES (1, 1, '2026-11-12', 100000, 100000);

-- ON DELETE CASCADE: al eliminar la compra de la nevera se eliminan sus cuotas
-- Resultado esperado: la consulta devuelve 0 cuotas
DELETE FROM movimiento WHERE id_movimiento = 9;
SELECT COUNT(*) AS cuotas_de_la_nevera FROM cuota WHERE id_movimiento = 9;

-- ON DELETE SET NULL: al eliminar un tercero, sus movimientos se conservan sin tercero
-- Resultado esperado: los movimientos 5 y 12 quedan con id_tercero en NULL
DELETE FROM tercero WHERE id_tercero = 1;
SELECT id_movimiento, descripcion, id_tercero FROM movimiento WHERE id_movimiento IN (5, 12);

-- UPDATE sin WHERE: intenta cambiar el correo de todas las personas
-- Resultado esperado: ERROR 1062; la restricción UNIQUE del correo evita el daño.
-- Sin esa restricción, todas las personas habrían quedado con el mismo correo.
UPDATE persona SET correo = 'nuevo@correo.com';

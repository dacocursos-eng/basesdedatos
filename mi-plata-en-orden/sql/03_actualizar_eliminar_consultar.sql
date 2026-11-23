-- ============================================================
-- Mi plata en orden · UPDATE, DELETE y SELECT
-- ============================================================

USE mi_plata_en_orden;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- UPDATE: actualizar registros
-- ------------------------------------------------------------

-- Sofía cambia su correo
UPDATE persona
SET correo = 'sofia.ramirez@correo.com'
WHERE id_persona = 1;

-- El banco aumenta el cupo de la tarjeta del supermercado
UPDATE cuenta
SET cupo = 6000000
WHERE id_cuenta = 3;

-- Sofía paga la segunda cuota de la nevera
UPDATE cuota
SET estado = 'pagada'
WHERE id_movimiento = 9 AND numero = 2;

-- Sofía cierra la billetera digital
UPDATE cuenta
SET estado = 'cerrada'
WHERE id_cuenta = 5;

-- ------------------------------------------------------------
-- DELETE: eliminar registros
-- ------------------------------------------------------------

-- Se retira la etiqueta familia del movimiento del hotel
DELETE FROM movimiento_etiqueta
WHERE id_movimiento = 8 AND id_etiqueta = 3;

-- Se elimina el pago fijo del gimnasio, que está inactivo y no tiene movimientos
DELETE FROM pago_fijo
WHERE id_pago_fijo = 4;

-- ------------------------------------------------------------
-- SELECT: consultar
-- ------------------------------------------------------------

-- Todas las columnas y todos los registros de la tabla persona
SELECT *
FROM persona;

-- Cuentas activas de Sofía
SELECT nombre, saldo_inicial, estado
FROM cuenta
WHERE id_persona = 1 AND estado = 'activa';

-- Movimientos de la cuenta Ahorros de la casa
SELECT fecha_ocurrencia, descripcion, valor
FROM movimiento
WHERE id_cuenta = 1;

-- Categorías de gasto del sistema
SELECT nombre
FROM categoria
WHERE naturaleza = 'gasto' AND id_persona IS NULL;

-- Movimientos de más de 500.000 pesos
SELECT id_movimiento, descripcion, valor
FROM movimiento
WHERE valor > 500000;

-- Cuotas pendientes
SELECT id_movimiento, numero, mes, capital, intereses_proyectados
FROM cuota
WHERE estado = 'pendiente';

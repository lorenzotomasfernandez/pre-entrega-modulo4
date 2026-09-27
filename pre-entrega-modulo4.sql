-- CONSULTA 1: RENTABILIDAD POR CATEGORÍA
-- Esta consulta permite identificar las categorías con mayor volumen de ventas
-- y conocer el ingreso total generado por cada una.
-- Se definió un umbral de más de 5 unidades vendidas para concentrar el análisis
-- en las categorías con mayor movimiento comercial.

SELECT
    c.nombre AS categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas v
JOIN productos p
    ON v.id_producto = p.id_producto
JOIN categorias c
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
HAVING SUM(v.cantidad) > 5;


-- CONSULTA 2: CLIENTES SIN COMPRAS
-- Esta consulta permite identificar clientes registrados que todavía no realizaron
-- ninguna compra, información útil para detectar clientes potenciales y realizar
-- acciones comerciales dirigidas a generar su primera compra.

SELECT
    c.nombre AS cliente,
    COALESCE(v.id_venta, 0) AS cantidad_compras
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- CONSULTA 3: TOP DE COMPRAS POR CLIENTE
-- Esta consulta permite identificar el producto que más unidades compró cada cliente
-- y la fecha de su última transacción. Esto permite conocer las preferencias de compra
-- de cada cliente y contar con información para orientar acciones comerciales.

SELECT
    ranking.cliente,
    ranking.producto AS producto_mas_comprado,
    ranking.total_comprado,
    ultima.ultima_transaccion
FROM (
    SELECT
        c.id_cliente,
        c.nombre AS cliente,
        p.nombre AS producto,
        SUM(v.cantidad) AS total_comprado,
        ROW_NUMBER() OVER (
            PARTITION BY c.id_cliente
            ORDER BY SUM(v.cantidad) DESC
        ) AS posicion
    FROM clientes c
    JOIN ventas v
        ON c.id_cliente = v.id_cliente
    JOIN productos p
        ON v.id_producto = p.id_producto
    GROUP BY c.id_cliente, c.nombre, p.id_producto, p.nombre
) AS ranking
JOIN (
    SELECT
        v.id_cliente,
        MAX(v.fecha_venta) AS ultima_transaccion
    FROM ventas v
    GROUP BY v.id_cliente
) AS ultima
    ON ranking.id_cliente = ultima.id_cliente
WHERE ranking.posicion = 1;
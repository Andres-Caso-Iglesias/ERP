/**
 * @file sales.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Maneja la lógica y las funciones del sistema de notificaciones, 
 *        alertas de stock o eventos importantes.
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middware/authMiddleware')

module.exports = (sql) => {

    // Obtener todas las ventas (Rp)
    router.get('/', authMiddleware.verifyToken, async (req, res) => {
        try {
            // Usa la conexión 'sql' para interactuar con la tabla 'sales'
            const sales = await sql`SELECT * FROM sales`;
            res.status(200).json(sales);
        } catch (err) {
            console.error('Error al obtener las ventas:', err);
            res.status(500).json({ msg: 'Error del servidor al obtener las ventas.' });
        }
    });

    // Añadir una nueva venta (Rp)
    router.post('/', authMiddleware.verifyToken, async (req, res) => {
        const { clientId, date, total, status } = req.body;

        if (!clientId || !total || !date) {
            return res.status(400).json({ msg: 'Faltan campos obligatorios para la venta.' });
        }

        try {
            const [newSale] = await sql`
                INSERT INTO sales (client_id, sale_date, total, status)
                VALUES (${clientId}, ${date}, ${total}, ${status || 'pending'})
                RETURNING *;
            `;
            res.status(201).json(newSale);
        } catch (err) {
            console.error('Error al añadir una venta:', err);
            res.status(500).json({ msg: 'Error del servidor al añadir la venta.' });
        }
    });

    // Modificar una venta existente (Rp)
    router.put('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;
        const { clientId, date, total, status } = req.body;

        try {
            const [updatedSale] = await sql`
                UPDATE sales
                SET client_id = ${clientId}, 
                    sale_date = ${date}, 
                    total = ${total}, 
                    status = ${status}
                WHERE id = ${id}
                RETURNING *;
            `;

            if (updatedSale) {
                res.status(200).json(updatedSale);
            } else {
                res.status(404).json({ msg: 'Venta no encontrada.' });
            }
        } catch (err) {
            console.error('Error al modificar una venta:', err);
            res.status(500).json({ msg: 'Error del servidor al modificar la venta.' });
        }
    });

    // Eliminar una venta (Rp)
    router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;

        try {
            const [deletedSale] = await sql`
                DELETE FROM sales WHERE id = ${id}
                RETURNING *;
            `;

            if (deletedSale) {
                res.status(200).json({ msg: 'Venta eliminada correctamente.' });
            } else {
                res.status(404).json({ msg: 'Venta no encontrada.' });
            }
        } catch (err) {
            console.error('Error al eliminar una venta:', err);
            res.status(500).json({ msg: 'Error del servidor al eliminar la venta.' });
        }
    });

    return router;
};
/**
 * @file accounting.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Maneja todas las rutas y la lógica para el registro de transacciones contables,
 *        como ingresos y gastos.
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middware/authMiddleware');

// La función exportada recibe la conexión 'sql' como parámetro
  module.exports = (sql) => {
    // Obtener todos los registros (Rp)
    router.get('/', authMiddleware.verifyToken, async (req, res) => {
        try {
            // Usa la conexión 'sql' para interactuar con la tabla 'accounting'
            const entries = await sql`SELECT * FROM accounting ORDER BY transaction_date DESC`;
            res.status(200).json(entries);
        } catch (err) {
            console.error('Error al obtener los registros:', err);
            res.status(500).json({ msg: 'Error del servidor al obtener los registros.' });
        }
    });

    // Añadir un nuevo registro (Rp)
    router.post('/', authMiddleware.verifyToken, async (req, res) => {
        const { date, description, amount, type, category } = req.body;

        if (!date || !description || !amount || !type) {
            return res.status(400).json({ msg: 'Faltan campos obligatorios para el registro.' });
        }

        try {
            const [newEntry] = await sql`
                INSERT INTO accounting (transaction_date, description, amount, type, category)
                VALUES (${date}, ${description}, ${amount}, ${type}, ${category || 'general'})
                RETURNING *;
            `;
            res.status(201).json(newEntry);
        } catch (err) {
            console.error('Error al añadir un registro:', err);
            res.status(500).json({ msg: 'Error del servidor al añadir el registro.' });
        }
    });

    // Modificar un registro contable existente (Rp)
    router.put('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;
        const { date, description, amount, type, category } = req.body;

        try {
            const [updatedEntry] = await sql`
                UPDATE accounting
                SET transaction_date = ${date},
                    description = ${description},
                    amount = ${amount},
                    type = ${type},
                    category = ${category}
                WHERE id = ${id}
                RETURNING *;
            `;

            if (updatedEntry) {
                res.status(200).json(updatedEntry);
            } else {
                res.status(404).json({ msg: 'Registro contable no encontrado.' });
            }
        } catch (err) {
            console.error('Error al modificar un registro contable:', err);
            res.status(500).json({ msg: 'Error del servidor al modificar el registro.' });
        }
    });

    // Eliminar un registro contable (Rp)
    router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;

        try {
            const [deletedEntry] = await sql`
                DELETE FROM accounting WHERE id = ${id}
                RETURNING *;
            `;

            if (deletedEntry) {
                res.status(200).json({ msg: 'Registro contable eliminado correctamente.' });
            } else {
                res.status(404).json({ msg: 'Registro contable no encontrado.' });
            }
        } catch (err) {
            console.error('Error al eliminar un registro contable:', err);
            res.status(500).json({ msg: 'Error del servidor al eliminar el registro.' });
        }
    });

    return router;
};
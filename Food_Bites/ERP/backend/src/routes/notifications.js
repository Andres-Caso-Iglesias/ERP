/**
 * @file notifications.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Maneja la lógica y las funciones del sistema de notificaciones, 
 *        como alertas de stock o eventos importantes.
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middware/authMiddleware');

  module.exports = (sql) => {
    // Obtener todas las notificaciones para un usuario (Rp)
    router.get('/', authMiddleware.verifyToken, async (req, res) => {
        try {
            // Asume que req.user.id está disponible desde el middleware
            const userId = req.user.id;
            const notifications = await sql`SELECT * FROM notifications WHERE user_id = ${userId} ORDER BY created_at DESC`;
            res.status(200).json(notifications);
        } catch (err) {
            console.error('Error al obtener las notificaciones:', err);
            res.status(500).json({ msg: 'Error del servidor al obtener las notificaciones.' });
        }
    });

    // Añadir una nueva notificación (Rp)
    router.post('/', authMiddleware.verifyToken, async (req, res) => {
        const { userId, message } = req.body;

        if (!userId || !message) {
            return res.status(400).json({ msg: 'Faltan campos obligatorios para la notificación.' });
        }

        try {
            const [newNotification] = await sql`
                INSERT INTO notifications (user_id, message, status)
                VALUES (${userId}, ${message}, 'unread')
                RETURNING *;
            `;
            res.status(201).json(newNotification);
        } catch (err) {
            console.error('Error al añadir una notificación:', err);
            res.status(500).json({ msg: 'Error del servidor al añadir la notificación.' });
        }
    });

    // Marcar una notificación como leída (Rp)
    router.put('/:id/read', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;
        const userId = req.user.id;

        try {
            const [updatedNotification] = await sql`
                UPDATE notifications
                SET status = 'read'
                WHERE id = ${id} AND user_id = ${userId}
                RETURNING *;
            `;

            if (updatedNotification) {
                res.status(200).json(updatedNotification);
            } else {
                res.status(404).json({ msg: 'Notificación no encontrada o no pertenece al usuario.' });
            }
        } catch (err) {
            console.error('Error al marcar la notificación como leída:', err);
            res.status(500).json({ msg: 'Error del servidor al modificar la notificación.' });
        }
    });
    
    // Eliminar una notificación (Rp)
    router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;
        const userId = req.user.id;

        try {
            const [deletedNotification] = await sql`
                DELETE FROM notifications WHERE id = ${id} AND user_id = ${userId}
                RETURNING *;
            `;

            if (deletedNotification) {
                res.status(200).json({ msg: 'Notificación eliminada correctamente.' });
            } else {
                res.status(404).json({ msg: 'Notificación no encontrada o no pertenece al usuario.' });
            }
        } catch (err) {
            console.error('Error al eliminar una notificación:', err);
            res.status(500).json({ msg: 'Error del servidor al eliminar la notificación.' });
        }
    });

    return router;
};
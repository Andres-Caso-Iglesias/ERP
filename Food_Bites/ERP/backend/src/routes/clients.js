/**
 * @file clients.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Maneja todas las rutas para la gestión de clientes (CRUD).
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middware/authMiddleware');

module.exports = (sql) => {
  // Obtener todos los clientes (Rp)
  router.get('/', authMiddleware.verifyToken, async (req, res) => {
    try {
      // Usa la conexión 'sql' para interactuar con la tabla 'clients'
      const clients = await sql`SELECT * FROM clients`;
      res.json(clients);
    } catch (err) {
      console.error(err);
      res.status(500).json({ msg: 'Error al obtener los clientes' });
      }
    });

  // Añadir un nuevo cliente (Rp)
  router.post('/', authMiddleware.verifyToken, async (req, res) => {
    const { name, email, phone, status } = req.body;
    if (!name) {
      return res.status(400).json({ msg: 'Por favor, incluye un nombre para el cliente' });
    }

    try {
      const [newClient] = await sql`
        INSERT INTO clients (name, email, phone, status)
        VALUES (${name}, ${email}, ${phone}, ${status})
        RETURNING *;
        `;
      res.status(201).json(newClient);
    } catch (err) {
      console.error(err);
      res.status(500).json({ msg: 'Error al añadir el cliente' });
    }
  });

  // Modificar un cliente (Rp)
  router.put('/:id', authMiddleware.verifyToken, async (req, res) => {
    const { id } = req.params;
    const { name, email, phone, status } = req.body;

    try {
      const [updatedClient] = await sql`
        UPDATE clients
        SET
          name = ${name},
          email = ${email},
          phone = ${phone},
          status = ${status}
        WHERE id = ${id}
        RETURNING *;
      `;

      if (updatedClient) {
        res.json(updatedClient);
      } else {
        res.status(404).json({ msg: 'Cliente no encontrado' });
      }
    } catch (err) {
      console.error(err);
      res.status(500).json({ msg: 'Error al modificar el cliente' });
    }
  });

  // Eliminar un cliente (Rp)
  router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
    const { id } = req.params;

    try {
      const [deletedClient] = await sql`
        DELETE FROM clients WHERE id = ${id} RETURNING *;
      `;

      if (deletedClient) {
        res.json({ msg: 'Cliente eliminado correctamente' });
      } else {
        res.status(404).json({ msg: 'Cliente no encontrado' });
      }
    } catch (err) {
      console.error(err);
      res.status(500).json({ msg: 'Error al eliminar el cliente' });
    }
  });

  return router; 
};
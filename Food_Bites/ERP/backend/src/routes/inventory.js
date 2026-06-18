/**
 * @file inventory.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Maneja todas las rutas para la gestión del inventario y el control de stock de productos.
 */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middware/authMiddleware');

module.exports = (sql) => {
  // Obtener todo el inventario (Rp)
  router.get('/', authMiddleware.verifyToken, async (req, res) => {
    try {
      // Usa la conexión 'sql' para interactuar con la tabla 'inventory'
      const inventory = await sql`SELECT * FROM inventory`;
      res.status(200).json(inventory);
    } catch (err) {
      console.error('Error al obtener el inventario:', err);
      res.status(500).json({ msg: 'Error del servidor al obtener el inventario.' });
    }
  });

    // Añadir un nuevo producto al inventario (Rp)
    router.post('/', authMiddleware.verifyToken, async (req, res) => {
        const { product_name, quantity, price } = req.body;

        if (!product_name || !quantity || !price) {
            return res.status(400).json({ msg: 'Faltan campos obligatorios: nombre, cantidad y precio.' });
        }

        try {
            const [newProduct] = await sql`
                INSERT INTO inventory (product_name, quantity, price)
                VALUES (${product_name}, ${quantity}, ${price})
                RETURNING *;
            `;
            res.status(201).json(newProduct);
        } catch (err) {
            console.error('Error al añadir un producto al inventario:', err);
            res.status(500).json({ msg: 'Error del servidor al añadir el producto.' });
        }
    });

    // Modificar un producto existente (Rp)
    router.put('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;
        const { product_name, quantity, price } = req.body;

        try {
            const [updatedProduct] = await sql`
                UPDATE inventory
                SET product_name = ${product_name}, 
                    quantity = ${quantity}, 
                    price = ${price}
                WHERE id = ${id}
                RETURNING *;
            `;

            if (updatedProduct) {
                res.status(200).json(updatedProduct);
            } else {
                res.status(404).json({ msg: 'Producto no encontrado.' });
            }
        } catch (err) {
            console.error('Error al modificar el producto:', err);
            res.status(500).json({ msg: 'Error del servidor al modificar el producto.' });
        }
    });

    // Eliminar un producto (Rp)
    router.delete('/:id', authMiddleware.verifyToken, async (req, res) => {
        const { id } = req.params;

        try {
            const [deletedProduct] = await sql`
                DELETE FROM inventory WHERE id = ${id}
                RETURNING *;
            `;

            if (deletedProduct) {
                res.status(200).json({ msg: 'Producto eliminado correctamente.' });
            } else {
                res.status(404).json({ msg: 'Producto no encontrado.' });
            }
        } catch (err) {
            console.error('Error al eliminar el producto:', err);
            res.status(500).json({ msg: 'Error del servidor al eliminar el producto.' });
        }
    });

    return router;
};
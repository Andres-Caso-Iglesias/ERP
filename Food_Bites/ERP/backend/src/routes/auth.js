/**
 * @file auth.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Enrutador principal que define y agrupa todas las rutas de autenticación (registro y login)
 */
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

module.exports = (sql) => {
    // Ruta registro de nuevos usuarios
    router.post('/register', authController.register(sql));

    // Ruta inicio de sesión
    router.post('/login', authController.login(sql));

    return router;
};
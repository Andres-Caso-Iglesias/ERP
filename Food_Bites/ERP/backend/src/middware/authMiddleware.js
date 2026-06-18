/**
 * @file authMiddleware.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief funciones de "middleware" para proteger rutas mediante la validación de tokens JWT.
 */
const jwt = require('jsonwebtoken');

const jwtSecret = process.env.JWT_SECRET;

// Middleware para verificar el token de autenticación
exports.verifyToken = (req, res, next) => {
    //Obtener el token del encabezado de la petición
    const token = req.header('Authorization');

    //Si no hay token, denegar el acceso
    if (!token) {
        return res.status(401).json({ msg: 'Acceso denegado. No hay token proporcionado.' });
    }

    try {
        //Extrae el token de "Bearer [token]"
        const tokenParts = token.split(' ');
        if (tokenParts.length !== 2 || tokenParts[0] !== 'Bearer') {
            return res.status(401).json({ msg: 'Formato de token inválido.' });
        }
        const tokenValue = tokenParts[1];

        //Verificar y decodificar el token
        const decoded = jwt.verify(tokenValue, jwtSecret);

        //Adjunta datos del usuario a la petición para su uso a posteriori
        req.user = decoded;
        
        next();
    } catch (error) {
        // Manejar errores de token inválido o expirado
        res.status(401).json({ msg: 'Token no válido.' });
    }
};
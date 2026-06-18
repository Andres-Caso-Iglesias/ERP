/**
 * @file authController.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief  Maneja toda la lógica de autenticación de usuarios, el registro, el inicio de sesión 
 *         y la generación de tokens JWT.
 */
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const saltRounds = 10;
const jwtSecret = process.env.JWT_SECRET;

// Función para el registro de un nuevo usuario
exports.register = (sql) => async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ msg: 'Por favor, introduce todos los campos.' });
    }

    try {
        //Hashear la contraseña antes de guardarla
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        //Inserta el nuevo usuario en la base de datos
        const [result] = await sql`
            INSERT INTO users (username, password_hash) 
            VALUES (${username}, ${hashedPassword})
            RETURNING *;
        `;

        res.status(201).json({ msg: 'Usuario registrado con éxito.' });
    } catch (error) {
        if (error.code === '23505') { // Código de error de duplicado en PostgreSQL
            return res.status(409).json({ msg: 'El nombre de usuario ya existe.' });
        }
        console.error('Error en el registro:', error);
        res.status(500).json({ msg: 'Error del servidor.' });
    }
};

// Función para el login de un usuario
exports.login = (sql) => async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ msg: 'Por favor, introduce todos los campos.' });
    }

    try {
        //Busca el usuario por nombre
        const [user] = await sql`
            SELECT * FROM users WHERE username = ${username}
        `;
        
        // debugging eliminar despues
        //console.log('Usuario encontrado:', user);
        //console.log('Contraseña del usuario (hash):', user ? user.password_hash : 'Usuario no encontrado');

        // Si el usuario no existe, envía un error de credenciales inválidas que no de info
        if (!user) {
            return res.status(400).json({ msg: 'Credenciales inválidas.' });
        }

        //Compara la contraseña ingresada con la hasheada de la base de datos
        const match = await bcrypt.compare(password, user.password_hash);

        // Si las contraseñas no coinciden, envía un error de credenciales
        if (!match) {
            return res.status(400).json({ msg: 'Credenciales inválidas.' });
        }

        //Generar un token de autenticación
        const token = jwt.sign({ id: user.id, username: user.username }, jwtSecret, { expiresIn: '1h' });

        // Enviar una respuesta exitosa con el token y los datos del usuario
        res.status(200).json({
            msg: 'Inicio de sesión exitoso.',
            token,
            user: {
                id: user.id,
                username: user.username,
            }
        });

    } catch (error) {
        console.error('Error en el login:', error);
        res.status(500).json({ msg: 'Error del servidor.' });
    }
};
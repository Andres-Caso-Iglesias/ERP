/**
 * @file index.js
 * @author Andres Caso Iglesias
 * @date Septiembre 2025
 * @brief Archivo principal que inicia el servidor, configura la conexión a la base de datos
 * y define todas las rutas de la API.
 */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const postgres = require('postgres');
const chalk = require('chalk').default;//para jugar con colores en terminal xD

const salesRoutes = require('./routes/sales');
const clientsRoutes = require('./routes/clients');
const inventoryRoutes = require('./routes/inventory');
const accountingRoutes = require('./routes/accounting');
const notificationsRoutes = require('./routes/notifications');
const authRoutes = require('./routes/auth');

// Se crea una única instancia de la conexión a la base de datos
const sql = postgres(process.env.DATABASE_URL);

// Función para probar la conexión a la base de datos con un toque visual
async function testDatabaseConnection() {
    try {
        await sql`SELECT 1`;
        console.log(chalk.green('🔗 Conexión a la base de datos exitosa.'));
    } catch (err) {
        console.error(chalk.red('❌ Error al conectar a la base de datos:'));
        console.error(err);//para detalles completos del error, no envolver con chalk
        console.log(chalk.yellow('🚪 Cerrando aplicacion'));
        process.exit(1); // Cierra la aplicación si la conexión falla
    }
}

// Middleware para procesar JSON
app.use(express.json());
// CORS para permitir la conexión desde el frontend (móvil y web)
app.use(cors());

// Montado de las rutas de modulos
app.use('/api/sales', salesRoutes(sql));
app.use('/api/clients', clientsRoutes(sql));
app.use('/api/inventory', inventoryRoutes(sql));
app.use('/api/accounting', accountingRoutes(sql));
app.use('/api/notifications', notificationsRoutes(sql));
// Ruta de autenticación
app.use('/api/auth', authRoutes(sql));

const PORT = process.env.PORT || 5000;

// Función asíncrona para iniciar el servidor después de la conexión a la base de datos
async function startServer() {
    console.log(chalk.blue('🚀 Iniciando servidor...'));
    await testDatabaseConnection();
    app.listen(PORT, '0.0.0.0', () => {
        console.log(chalk.yellow(`Server is running on port`) + chalk.magenta(` ${PORT}`)); 
    });
}

// Llama a la función para iniciar el servidor que si no no chufla
startServer();
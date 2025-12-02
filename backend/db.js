const mysql = require('mysql2/promise');
require('dotenv').config();

async function createPool() {
const pool = await mysql.createPool({
host: process.env.DB_HOST || 'localhost',
user: process.env.DB_USER || 'root',
password: process.env.DB_PASSWORD || '',
database: process.env.DB_NAME || 'wordle_app',
waitForConnections: true,
connectionLimit: 10,
queueLimit: 0
});
return pool;
}

module.exports = createPool;
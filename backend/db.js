const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '123adem123',
    database: process.env.DB_NAME || 'telemedicine_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

pool.getConnection((err, connection) => {
    if (err) {
        console.error('Veritabanı bağlantı hatası: ' + err.message);
    } else {
        console.log('MySQL Veritabanına başarıyla bağlanıldı! 🚀');
        connection.release();
    }
});

module.exports = pool.promise();
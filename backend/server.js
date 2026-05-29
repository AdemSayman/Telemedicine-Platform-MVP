const express = require('express');
const path = require('path');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const db = require('./db');
const authRoutes = require('./routes/authRoutes');
const doctorRoutes = require('./routes/doctorRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const prescriptionRoutes = require('./routes/prescriptionRoutes');
const userRoutes = require('./routes/userRoutes');
const notFound = require('./middleware/notFound');
const errorHandler = require('./middleware/errorHandler');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

const swaggerSpec = swaggerJsdoc({
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Moritanya Telemedicine API',
            version: '1.0.0',
            description: 'FSM tabanlı Tele-Tıp Platformu API Dökümantasyonu'
        },
        servers: [
            {
                url: `http://localhost:${port}/api`,
                description: 'Local development server'
            }
        ],
        tags: [
            {
                name: 'Auth',
                description: 'Authentication and patient registration endpoints'
            },
            {
                name: 'Doctors',
                description: 'Doctor listing and doctor detail endpoints'
            },
            {
                name: 'Appointments',
                description: 'Appointment creation, listing and status update endpoints'
            },
            {
                name: 'Prescriptions',
                description: 'Prescription creation and QR payload endpoints'
            }
        ]
    },
    apis: [path.join(__dirname, 'routes/*.js')]
});

app.use(cors());
app.use(express.json());
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.get('/api-docs.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
});

app.get('/', (req, res) => {
    res.status(200).json({
        message: 'Telemedicine backend is running successfully.'
    });
});

app.get('/api/health', async (req, res, next) => {
    try {
        const [rows] = await db.query('SELECT COUNT(*) AS user_count FROM users');

        return res.status(200).json({
            message: 'Database connection is active.',
            data: {
                user_count: rows[0].user_count
            }
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'Database health check failed.';
        return next(error);
    }
});

app.use('/api/auth', authRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/prescriptions', prescriptionRoutes);
app.use('/api/users', userRoutes);

app.use(notFound);
app.use(errorHandler);

app.listen(port, () => {
    console.log(`Server is listening on http://localhost:${port}`);
});

const express = require('express');
const {
    createAppointment,
    getPatientAppointments,
    getDoctorAppointments,
    updateAppointmentStatus
} = require('../controllers/appointmentController');

const router = express.Router();

/**
 * @swagger
 * /appointments:
 *   post:
 *     summary: Create a new appointment
 *     tags:
 *       - Appointments
 *     responses:
 *       201:
 *         description: Appointment created successfully.
 */
router.post('/', createAppointment);

/**
 * @swagger
 * /appointments/patient/{patientId}:
 *   get:
 *     summary: List appointments for a patient
 *     tags:
 *       - Appointments
 *     responses:
 *       200:
 *         description: Patient appointments retrieved successfully.
 */
router.get('/patient/:patientId', getPatientAppointments);

/**
 * @swagger
 * /appointments/doctor/{doctorId}:
 *   get:
 *     summary: List appointments for a doctor
 *     tags:
 *       - Appointments
 *     parameters:
 *       - in: path
 *         name: doctorId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Doctor appointments retrieved successfully.
 */
router.get('/doctor/:doctorId', getDoctorAppointments);

/**
 * @swagger
 * /appointments/{id}/status:
 *   patch:
 *     summary: Update appointment status and payment state
 *     tags:
 *       - Appointments
 *     responses:
 *       200:
 *         description: Appointment status updated successfully.
 */
router.patch('/:id/status', updateAppointmentStatus);

module.exports = router;

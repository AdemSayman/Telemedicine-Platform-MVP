const express = require('express');
const { createPrescription } = require('../controllers/prescriptionController');

const router = express.Router();

/**
 * @swagger
 * /prescriptions:
 *   post:
 *     summary: Create a prescription for a completed appointment
 *     tags:
 *       - Prescriptions
 *     responses:
 *       201:
 *         description: Prescription created successfully.
 */
router.post('/', createPrescription);

module.exports = router;

const express = require('express');
const {
    getAllDoctors,
    getDoctorById
} = require('../controllers/doctorController');

const router = express.Router();

/**
 * @swagger
 * /doctors:
 *   get:
 *     summary: List all doctors
 *     description: Returns all doctors with their specialty, experience and availability details.
 *     tags:
 *       - Doctors
 *     parameters:
 *       - in: query
 *         name: specialty
 *         schema:
 *           type: string
 *         required: false
 *         description: Filter doctors by specialty.
 *         example: "Kardiyoloji"
 *     responses:
 *       200:
 *         description: Doctors retrieved successfully.
 *       500:
 *         description: Unexpected database error while fetching doctors.
 */
router.get('/', getAllDoctors);

/**
 * @swagger
 * /doctors/{id}:
 *   get:
 *     summary: Get doctor details by id
 *     tags:
 *       - Doctors
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Doctor details retrieved successfully.
 *       404:
 *         description: Doctor not found.
 */
router.get('/:id', getDoctorById);

module.exports = router;

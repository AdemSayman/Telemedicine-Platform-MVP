const express = require('express');
const { loginOrRegister } = require('../controllers/authController');

const router = express.Router();

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login or register a patient using phone number
 *     description: Returns the existing user if the phone number is found, otherwise creates a new patient account.
 *     tags:
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone_number
 *             properties:
 *               phone_number:
 *                 type: string
 *                 example: "+22220000031"
 *               full_name:
 *                 type: string
 *                 example: "Salka Mint Ahmed"
 *     responses:
 *       200:
 *         description: Existing user authenticated successfully.
 *       201:
 *         description: New patient account created successfully.
 *       400:
 *         description: Invalid or missing phone number.
 */
router.post('/login', loginOrRegister);

router.post('/login-or-register', loginOrRegister);

module.exports = router;

const express = require('express');
const { updateProfile } = require('../controllers/userController');

const router = express.Router();

/**
 * @swagger
 * /users/profile:
 *   patch:
 *     summary: Update the authenticated user's profile.
 *     tags:
 *       - Users
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *             properties:
 *               user_id:
 *                 type: integer
 *                 example: 1
 *               full_name:
 *                 type: string
 *                 example: "Salka Mint Ahmed"
 *               phone_number:
 *                 type: string
 *                 example: "+22220000031"
 *     responses:
 *       200:
 *         description: Profile updated successfully.
 */
router.patch('/profile', updateProfile);

module.exports = router;

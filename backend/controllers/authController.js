const db = require('../db');

const MAURITANIA_PHONE_REGEX = /^\+222\d{8}$/;
const ALLOWED_USER_ROLES = ['patient', 'doctor'];

function buildDefaultPatientName(phoneNumber) {
    return `Patient ${phoneNumber.slice(-4)}`;
}

function buildDefaultDoctorName(phoneNumber) {
    return `Doctor ${phoneNumber.slice(-4)}`;
}

async function loginOrRegister(req, res, next) {
    const {
        phone_number: phoneNumber,
        full_name: fullName,
        role: rawRole,
        specialty: rawSpecialty,
        experience_years: rawExperienceYears
    } = req.body;

    const role = rawRole ? rawRole.toString().trim().toLowerCase() : 'patient';
    const specialty = rawSpecialty?.toString().trim() || 'Genel';
    const experienceYears = Number(rawExperienceYears) > 0
        ? Number(rawExperienceYears)
        : 3;

    if (!phoneNumber) {
        return res.status(400).json({
            message: 'Phone number is required to continue authentication.'
        });
    }

    if (!MAURITANIA_PHONE_REGEX.test(phoneNumber)) {
        return res.status(400).json({
            message: 'Phone number must be in Mauritania format and start with +222 followed by 8 digits.'
        });
    }

    if (!ALLOWED_USER_ROLES.includes(role)) {
        return res.status(400).json({
            message: `Role must be one of: ${ALLOWED_USER_ROLES.join(', ')}.`
        });
    }

    try {
        const [existingUsers] = await db.query(
            `SELECT id, phone_number, full_name, role, created_at
             FROM users
             WHERE phone_number = ?
             LIMIT 1`,
            [phoneNumber]
        );

        if (existingUsers.length > 0) {
            const existingUser = existingUsers[0];
            if (existingUser.role !== role) {
                return res.status(409).json({
                    message: `Phone number is already registered as ${existingUser.role}. Please use the correct role or a different phone number.`
                });
            }

            return res.status(200).json({
                message: 'User authenticated successfully.',
                data: existingUser
            });
        }

        const normalizedFullName = fullName && fullName.trim()
            ? fullName.trim()
            : role === 'doctor'
                ? buildDefaultDoctorName(phoneNumber)
                : buildDefaultPatientName(phoneNumber);

        const [insertResult] = await db.query(
            `INSERT INTO users (phone_number, full_name, role)
             VALUES (?, ?, ?)`,
            [phoneNumber, normalizedFullName, role]
        );

        if (role === 'doctor') {
            await db.query(
                `INSERT INTO doctors (user_id, specialty, experience_years, is_available)
                 VALUES (?, ?, ?, TRUE)`,
                [insertResult.insertId, specialty, experienceYears]
            );
        }

        const [newUsers] = await db.query(
            `SELECT id, phone_number, full_name, role, created_at
             FROM users
             WHERE id = ?`,
            [insertResult.insertId]
        );

        return res.status(201).json({
            message: `New ${role} account created successfully.`,
            data: newUsers[0]
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while processing authentication.';
        return next(error);
    }
}

module.exports = {
    loginOrRegister
};

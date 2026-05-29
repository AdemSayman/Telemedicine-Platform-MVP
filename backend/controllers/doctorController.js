const db = require('../db');

async function getAllDoctors(req, res, next) {
    const { specialty } = req.query;

    try {
        let query = `
            SELECT
                d.id AS doctor_id,
                d.user_id,
                u.full_name,
                u.phone_number,
                d.specialty,
                d.experience_years,
                d.is_available,
                u.created_at
            FROM doctors d
            INNER JOIN users u ON u.id = d.user_id
        `;
        const params = [];

        if (specialty) {
            query += ' WHERE d.specialty = ?';
            params.push(specialty);
        }

        query += ' ORDER BY d.specialty ASC, u.full_name ASC';

        const [doctors] = await db.query(query, params);

        return res.status(200).json({
            message: 'Doctors retrieved successfully.',
            data: doctors
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while fetching doctors.';
        return next(error);
    }
}

async function getDoctorById(req, res, next) {
    const { id } = req.params;

    if (!Number.isInteger(Number(id))) {
        return res.status(400).json({
            message: 'Doctor id must be a valid numeric value.'
        });
    }

    try {
        const [doctors] = await db.query(
            `SELECT
                d.id AS doctor_id,
                d.user_id,
                u.full_name,
                u.phone_number,
                d.specialty,
                d.experience_years,
                d.is_available,
                u.created_at
             FROM doctors d
             INNER JOIN users u ON u.id = d.user_id
             WHERE d.id = ?
             LIMIT 1`,
            [id]
        );

        if (doctors.length === 0) {
            return res.status(404).json({
                message: 'Doctor could not be found with the provided id.'
            });
        }

        return res.status(200).json({
            message: 'Doctor details retrieved successfully.',
            data: doctors[0]
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while fetching the doctor details.';
        return next(error);
    }
}

module.exports = {
    getAllDoctors,
    getDoctorById
};

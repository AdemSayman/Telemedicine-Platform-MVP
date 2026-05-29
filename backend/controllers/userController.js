const db = require('../db');

async function updateProfile(req, res, next) {
    const {
        user_id: userId,
        full_name: fullName,
        phone_number: phoneNumber,
    } = req.body;

    if (!userId) {
        return res.status(400).json({
            message: 'User id is required to update profile.',
        });
    }

    if (!fullName && !phoneNumber) {
        return res.status(400).json({
            message: 'At least one field must be provided to update profile.',
        });
    }

    try {
        if (phoneNumber) {
            const [conflictRows] = await db.query(
                'SELECT id FROM users WHERE phone_number = ? AND id != ? LIMIT 1',
                [phoneNumber, userId]
            );

            if (conflictRows.length > 0) {
                return res.status(409).json({
                    message: 'This phone number is already used by another account.',
                });
            }
        }

        const updateFields = [];
        const updateValues = [];

        if (fullName) {
            updateFields.push('full_name = ?');
            updateValues.push(fullName);
        }
        if (phoneNumber) {
            updateFields.push('phone_number = ?');
            updateValues.push(phoneNumber);
        }

        updateValues.push(userId);

        await db.query(
            `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`,
            updateValues
        );

        const [rows] = await db.query(
            'SELECT id, phone_number, full_name, role, created_at FROM users WHERE id = ? LIMIT 1',
            [userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                message: 'User not found.',
            });
        }

        return res.status(200).json({
            message: 'Profil başarıyla güncellendi.',
            data: rows[0],
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while updating profile.';
        return next(error);
    }
}

module.exports = {
    updateProfile,
};

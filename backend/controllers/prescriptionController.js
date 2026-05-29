const db = require('../db');

let QRCode;

try {
    QRCode = require('qrcode');
} catch (error) {
    QRCode = null;
}

function buildQrCodeData(appointmentId) {
    return `QR_DOC_${appointmentId}_${Date.now()}`;
}

async function createPrescription(req, res, next) {
    const {
        appointment_id: appointmentId,
        diagnosis,
        medications
    } = req.body;

    if (!appointmentId || !diagnosis || !medications) {
        return res.status(400).json({
            message: 'appointment_id, diagnosis and medications are required to create a prescription.'
        });
    }

    try {
        const [appointments] = await db.query(
            `SELECT
                a.id,
                a.patient_id,
                a.doctor_id,
                a.status
             FROM appointments a
             WHERE a.id = ?
             LIMIT 1`,
            [appointmentId]
        );

        if (appointments.length === 0) {
            return res.status(404).json({
                message: 'Appointment could not be found with the provided id.'
            });
        }

        const appointment = appointments[0];

        if (appointment.status !== 'completed') {
            return res.status(409).json({
                message: 'A prescription can only be added to a completed appointment.'
            });
        }

        const [existingPrescriptions] = await db.query(
            `SELECT id
             FROM prescriptions
             WHERE appointment_id = ?
             LIMIT 1`,
            [appointmentId]
        );

        if (existingPrescriptions.length > 0) {
            return res.status(409).json({
                message: 'A prescription already exists for this appointment.'
            });
        }

        const qrCodeData = buildQrCodeData(appointmentId);

        const [insertResult] = await db.query(
            `INSERT INTO prescriptions (appointment_id, diagnosis, medications, qr_code_data)
             VALUES (?, ?, ?, ?)`,
            [appointmentId, diagnosis, medications, qrCodeData]
        );

        const qrPayload = {
            prescription_id: insertResult.insertId,
            appointment_id: appointment.id,
            patient_id: appointment.patient_id,
            doctor_id: appointment.doctor_id,
            qr_code_data: qrCodeData
        };

        const qrCodeImage = QRCode
            ? await QRCode.toDataURL(JSON.stringify(qrPayload))
            : null;

        const [prescriptions] = await db.query(
            `SELECT id, appointment_id, diagnosis, medications, qr_code_data, created_at
             FROM prescriptions
             WHERE id = ?
             LIMIT 1`,
            [insertResult.insertId]
        );

        return res.status(201).json({
            message: 'Prescription created successfully.',
            data: {
                ...prescriptions[0],
                qr_code: {
                    raw_value: qrCodeData,
                    payload: qrPayload,
                    image_data_url: qrCodeImage
                }
            }
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while creating the prescription.';
        return next(error);
    }
}

module.exports = {
    createPrescription
};

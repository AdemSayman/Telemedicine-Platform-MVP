const crypto = require('crypto');
const db = require('../db');

let RtcRole;
let RtcTokenBuilder;

try {
    ({ RtcRole, RtcTokenBuilder } = require('agora-access-token'));
} catch (error) {
    RtcRole = null;
    RtcTokenBuilder = null;
}

const ALLOWED_APPOINTMENT_STATUSES = ['pending', 'paid', 'completed', 'cancelled'];

function generateFallbackToken() {
    return crypto.randomBytes(24).toString('hex');
}

function normalizeBooleanInput(value) {
    if (value === true || value === 1 || value === '1' || value === 'true') {
        return true;
    }

    if (value === false || value === 0 || value === '0' || value === 'false') {
        return false;
    }

    return null;
}

function generateAgoraToken(channelName) {
    const appId = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;

    if (RtcTokenBuilder && RtcRole && appId && appCertificate) {
        const privilegeExpiredTs = Math.floor(Date.now() / 1000) + 60 * 60;

        return RtcTokenBuilder.buildTokenWithUid(
            appId,
            appCertificate,
            channelName,
            0,
            RtcRole.PUBLISHER,
            privilegeExpiredTs
        );
    }

    return generateFallbackToken();
}

async function createAppointment(req, res, next) {
    const { patient_id: patientId, doctor_id: doctorId, appointment_date: appointmentDate } = req.body;

    if (!patientId || !doctorId || !appointmentDate) {
        return res.status(400).json({
            message: 'patient_id, doctor_id and appointment_date are required to create an appointment.'
        });
    }

    const parsedAppointmentDate = new Date(appointmentDate);

    if (Number.isNaN(parsedAppointmentDate.getTime())) {
        return res.status(400).json({
            message: 'appointment_date must be a valid ISO date value.'
        });
    }

    if (parsedAppointmentDate <= new Date()) {
        return res.status(400).json({
            message: 'appointment_date must be in the future when creating a new appointment.'
        });
    }

    try {
        const [patients] = await db.query(
            `SELECT id, full_name, role
             FROM users
             WHERE id = ? AND role = 'patient'
             LIMIT 1`,
            [patientId]
        );

        if (patients.length === 0) {
            return res.status(404).json({
                message: 'Patient could not be found with the provided id.'
            });
        }

        const [doctors] = await db.query(
            `SELECT
                d.id,
                d.specialty,
                d.is_available,
                u.full_name
             FROM doctors d
             INNER JOIN users u ON u.id = d.user_id
             WHERE d.id = ?
             LIMIT 1`,
            [doctorId]
        );

        if (doctors.length === 0) {
            return res.status(404).json({
                message: 'Doctor could not be found with the provided id.'
            });
        }

        if (!doctors[0].is_available) {
            return res.status(409).json({
                message: 'The selected doctor is currently not available for new appointments.'
            });
        }

        const channelName = `appointment-${doctorId}-${patientId}-${Date.now()}`;
        const agoraToken = generateAgoraToken(channelName);

        const [insertResult] = await db.query(
            `INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, payment_status, agora_token)
             VALUES (?, ?, ?, 'pending', FALSE, ?)`,
            [patientId, doctorId, appointmentDate, agoraToken]
        );

        const [appointments] = await db.query(
            `SELECT
                a.id,
                a.patient_id,
                a.doctor_id,
                a.appointment_date,
                a.status,
                a.payment_status,
                a.agora_token,
                a.created_at
             FROM appointments a
             WHERE a.id = ?
             LIMIT 1`,
            [insertResult.insertId]
        );

        return res.status(201).json({
            message: 'Appointment created successfully.',
            data: appointments[0]
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while creating the appointment.';
        return next(error);
    }
}

async function getPatientAppointments(req, res, next) {
    const { patientId } = req.params;

    if (!Number.isInteger(Number(patientId))) {
        return res.status(400).json({
            message: 'Patient id must be a valid numeric value.'
        });
    }

    try {
        const [patients] = await db.query(
            `SELECT id, full_name
             FROM users
             WHERE id = ? AND role = 'patient'
             LIMIT 1`,
            [patientId]
        );

        if (patients.length === 0) {
            return res.status(404).json({
                message: 'Patient could not be found with the provided id.'
            });
        }

        const [appointments] = await db.query(
            `SELECT
                a.id,
                a.appointment_date,
                a.status,
                a.payment_status,
                a.agora_token,
                a.created_at,
                d.id AS doctor_id,
                du.full_name AS doctor_name,
                d.specialty
             FROM appointments a
             INNER JOIN doctors d ON d.id = a.doctor_id
             INNER JOIN users du ON du.id = d.user_id
             WHERE a.patient_id = ?
             ORDER BY a.appointment_date DESC`,
            [patientId]
        );

        return res.status(200).json({
            message: 'Patient appointments retrieved successfully.',
            data: {
                patient: patients[0],
                appointments
            }
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while fetching patient appointments.';
        return next(error);
    }
}

async function getDoctorAppointments(req, res, next) {
    const { doctorId } = req.params;

    if (!Number.isInteger(Number(doctorId))) {
        return res.status(400).json({
            message: 'Doctor id must be a valid numeric value.'
        });
    }

    try {
        const [doctors] = await db.query(
            `SELECT id
             FROM doctors
             WHERE id = ?
             LIMIT 1`,
            [doctorId]
        );

        if (doctors.length === 0) {
            return res.status(404).json({
                message: 'Doctor could not be found with the provided id.'
            });
        }

        const [appointments] = await db.query(
            `SELECT
                a.id,
                a.appointment_date,
                a.status,
                a.payment_status,
                a.agora_token,
                a.created_at,
                u.id AS patient_id,
                u.full_name AS patient_name,
                u.phone_number AS patient_phone,
                d.id AS doctor_id,
                du.full_name AS doctor_name,
                d.specialty
             FROM appointments a
             INNER JOIN users u ON u.id = a.patient_id
             INNER JOIN doctors d ON d.id = a.doctor_id
             INNER JOIN users du ON du.id = d.user_id
             WHERE a.doctor_id = ?
             ORDER BY a.appointment_date DESC`,
            [doctorId]
        );

        return res.status(200).json({
            message: 'Doctor appointments retrieved successfully.',
            data: {
                doctor: doctors[0],
                appointments
            }
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while fetching doctor appointments.';
        return next(error);
    }
}

async function updateAppointmentStatus(req, res, next) {
    const { id } = req.params;
    const { status, payment_status: paymentStatus } = req.body;
    const normalizedPaymentStatus = paymentStatus !== undefined
        ? normalizeBooleanInput(paymentStatus)
        : undefined;

    if (!Number.isInteger(Number(id))) {
        return res.status(400).json({
            message: 'Appointment id must be a valid numeric value.'
        });
    }

    if (status === undefined && paymentStatus === undefined) {
        return res.status(400).json({
            message: 'At least one of status or payment_status must be provided.'
        });
    }

    if (status !== undefined && !ALLOWED_APPOINTMENT_STATUSES.includes(status)) {
        return res.status(400).json({
            message: `status must be one of: ${ALLOWED_APPOINTMENT_STATUSES.join(', ')}.`
        });
    }

    if (paymentStatus !== undefined && normalizedPaymentStatus === null) {
        return res.status(400).json({
            message: 'payment_status must be a boolean, 0/1, or true/false string value.'
        });
    }

    if (status === 'paid' && normalizedPaymentStatus === false) {
        return res.status(400).json({
            message: 'A paid appointment must have payment_status set to true.'
        });
    }

    try {
        const [appointments] = await db.query(
            `SELECT id, status, payment_status, appointment_date
             FROM appointments
             WHERE id = ?
             LIMIT 1`,
            [id]
        );

        if (appointments.length === 0) {
            return res.status(404).json({
                message: 'Appointment could not be found with the provided id.'
            });
        }

        const currentAppointment = appointments[0];
        const nextStatus = status !== undefined ? status : currentAppointment.status;
        const nextPaymentStatus = normalizedPaymentStatus !== undefined
            ? normalizedPaymentStatus
            : Boolean(currentAppointment.payment_status);

        if (nextStatus === 'paid' && !nextPaymentStatus) {
            return res.status(400).json({
                message: 'A paid appointment must have payment_status set to true.'
            });
        }

        if (nextStatus === 'completed' && new Date(currentAppointment.appointment_date) > new Date()) {
            return res.status(409).json({
                message: 'A future appointment cannot be marked as completed.'
            });
        }

        await db.query(
            `UPDATE appointments
             SET status = ?, payment_status = ?
             WHERE id = ?`,
            [nextStatus, nextPaymentStatus, id]
        );

        const [updatedAppointments] = await db.query(
            `SELECT id, patient_id, doctor_id, appointment_date, status, payment_status, agora_token, created_at
             FROM appointments
             WHERE id = ?
             LIMIT 1`,
            [id]
        );

        return res.status(200).json({
            message: 'Appointment status updated successfully.',
            data: updatedAppointments[0]
        });
    } catch (error) {
        error.statusCode = 500;
        error.message = 'An unexpected database error occurred while updating the appointment status.';
        return next(error);
    }
}

module.exports = {
    createAppointment,
    getPatientAppointments,
    getDoctorAppointments,
    updateAppointmentStatus
};

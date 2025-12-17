import {
    addParticipant,
    createTorneo,
    getTorneoById,
    getTorneos
} from "../services/torneo.service.js";

import { handleErrorClient, handleErrorServer, handleSuccess } from "../handlers/responseHandlers.js";
import { createTorneoValidation } from "../validations/torneo.validation.js";

export async function createTorneoController(req, res) {
    try {
        const { error, value } = createTorneoValidation.validate(req.body);
        if (error) {
            return handleErrorClient(res, 400, "Error de validación", error.details[0].message);
        }

        // Add userId from authenticated user (assuming it's in req.user)
        // If req.user is not populated, we might need to adjust based on auth middleware
        // For now, assuming req.user.id exists
        const torneoData = {
            ...value,
            userId: req.user.id,
        };

        const [torneo, errorCreate] = await createTorneo(torneoData);
        if (errorCreate) return handleErrorClient(res, 400, "Error creando torneo", errorCreate);

        handleSuccess(res, 201, "Torneo creado exitosamente", torneo);
    } catch (error) {
        handleErrorServer(res, 500, error.message);
    }
}

export async function getTorneosController(req, res) {
    try {
        const [torneos, error] = await getTorneos();
        if (error) return handleErrorClient(res, 400, "Error obteniendo torneos", error);

        handleSuccess(res, 200, "Torneos encontrados", torneos);
    } catch (error) {
        handleErrorServer(res, 500, error.message);
    }
}

export async function getTorneoByIdController(req, res) {
    try {
        const { id } = req.params;
        const [torneo, error] = await getTorneoById(id);

        if (error) return handleErrorClient(res, 404, error); // 404 for not found

        handleSuccess(res, 200, "Torneo encontrado", torneo);
    } catch (error) {
        handleErrorServer(res, 500, error.message);
    }
}

export async function addParticipantController(req, res) {
    try {
        const { id } = req.params;
        const { userId } = req.body;

        if (!userId) {
            return handleErrorClient(res, 400, "Falta el userId en el cuerpo de la solicitud");
        }

        const [registro, error] = await addParticipant(id, userId);
        if (error) return handleErrorClient(res, 400, "Error inscribiendo usuario", error);

        handleSuccess(res, 201, "Usuario inscrito exitosamente", registro);
    } catch (error) {
        handleErrorServer(res, 500, error.message);
    }
}

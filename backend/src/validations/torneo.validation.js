"use strict";
import Joi from "joi";

export const createTorneoValidation = Joi.object({
    nombre: Joi.string().min(3).max(255).required()
        .messages({
            "string.base": "El nombre debe ser de tipo texto.",
            "string.empty": "El nombre no puede estar vacío.",
            "string.min": "El nombre debe tener como mínimo 3 caracteres.",
            "string.max": "El nombre debe tener como máximo 255 caracteres.",
            "any.required": "El nombre es obligatorio."
        }),
    descripcion: Joi.string().allow(null, "").optional(),
    fechaInicio: Joi.date().required()
        .messages({
            "date.base": "La fecha de inicio debe ser una fecha válida.",
            "any.required": "La fecha de inicio es obligatoria."
        }),
    premio: Joi.number().integer().min(0).required()
        .messages({
            "number.base": "El premio debe ser un número.",
            "number.integer": "El premio debe ser un número entero.",
            "number.min": "El premio no puede ser negativo.",
            "any.required": "El premio es obligatorio."
        }),
});

"use strict";
import Joi from "joi";

/**
 * Esquema de validación para crear un marcador
 */
export const marcadorBodyValidation = Joi.object({
  visitas: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Las visitas deben ser un número.",
      "number.integer": "Las visitas deben ser un número entero.",
      "number.min": "Las visitas no pueden ser negativas.",
    }),
  horas: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Las horas deben ser un número.",
      "number.integer": "Las horas deben ser un número entero.",
      "number.min": "Las horas no pueden ser negativas.",
    }),
  puntos: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Los puntos deben ser un número.",
      "number.integer": "Los puntos deben ser un número entero.",
      "number.min": "Los puntos no pueden ser negativos.",
    }),
  userId: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "El ID del usuario debe ser un número.",
      "number.integer": "El ID del usuario debe ser un número entero.",
      "number.positive": "El ID del usuario debe ser positivo.",
      "any.required": "El ID del usuario es obligatorio.",
    }),
}).messages({
  "object.unknown": "No se permiten propiedades adicionales.",
});

/**
 * Esquema de validación para actualizar un marcador
 */
export const marcadorUpdateValidation = Joi.object({
  visitas: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Las visitas deben ser un número.",
      "number.integer": "Las visitas deben ser un número entero.",
      "number.min": "Las visitas no pueden ser negativas.",
    }),
  horas: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Las horas deben ser un número.",
      "number.integer": "Las horas deben ser un número entero.",
      "number.min": "Las horas no pueden ser negativas.",
    }),
  puntos: Joi.number()
    .integer()
    .min(0)
    .messages({
      "number.base": "Los puntos deben ser un número.",
      "number.integer": "Los puntos deben ser un número entero.",
      "number.min": "Los puntos no pueden ser negativos.",
    }),
})
  .min(1)
  .messages({
    "object.min": "Debe proporcionar al menos un campo para actualizar.",
    "object.unknown": "No se permiten propiedades adicionales.",
  });

/**
 * Esquema de validación para el ID del marcador
 */
export const marcadorIdValidation = Joi.object({
  id: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "El ID debe ser un número.",
      "number.integer": "El ID debe ser un número entero.",
      "number.positive": "El ID debe ser un número positivo.",
      "any.required": "El ID es obligatorio.",
    }),
});

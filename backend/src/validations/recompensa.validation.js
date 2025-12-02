"use strict";
import Joi from "joi";

/**
 * Validación para el cuerpo de una recompensa
 */
export const recompensaBodyValidation = Joi.object({
  nombre: Joi.string()
    .min(3)
    .max(255)
    .messages({
      "string.empty": "El nombre no puede estar vacío.",
      "string.base": "El nombre debe ser de tipo string.",
      "string.min": "El nombre debe tener como mínimo 3 caracteres.",
      "string.max": "El nombre debe tener como máximo 255 caracteres.",
    }),
  costoEnPuntos: Joi.number()
    .integer()
    .positive()
    .messages({
      "number.base": "El costo en puntos debe ser un número.",
      "number.integer": "El costo en puntos debe ser un número entero.",
      "number.positive": "El costo en puntos debe ser un número positivo.",
    }),
  activo: Joi.boolean()
    .messages({
      "boolean.base": "El campo activo debe ser un valor booleano.",
    }),
})
  .or("nombre", "costoEnPuntos","activo")
  .unknown(false)
  .messages({
    "object.unknown": "No se permiten propiedades adicionales.",
    "object.missing": "Debes proporcionar al menos un campo para actualizar.",
  });

/**
 * Validación para crear una recompensa (requiere campos obligatorios)
 */
export const recompensaCreateValidation = Joi.object({
  nombre: Joi.string()
    .min(3)
    .max(255)
    .required()
    .messages({
      "string.empty": "El nombre no puede estar vacío.",
      "string.base": "El nombre debe ser de tipo string.",
      "string.min": "El nombre debe tener como mínimo 3 caracteres.",
      "string.max": "El nombre debe tener como máximo 255 caracteres.",
      "any.required": "El nombre es obligatorio.",
    }),
  costoEnPuntos: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "El costo en puntos debe ser un número.",
      "number.integer": "El costo en puntos debe ser un número entero.",
      "number.positive": "El costo en puntos debe ser un número positivo.",
      "any.required": "El costo en puntos es obligatorio.",
    }),
  activo: Joi.boolean()
    .default(true)
    .messages({
      "boolean.base": "El campo activo debe ser un valor booleano.",
    }),
})
  .unknown(false)
  .messages({
    "object.unknown": "No se permiten propiedades adicionales.",
  });

/**
 * Validación para el ID de una recompensa
 */
export const recompensaIdValidation = Joi.object({
  id: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "El id debe ser un número.",
      "number.integer": "El id debe ser un número entero.",
      "number.positive": "El id debe ser un número positivo.",
      "any.required": "El id es obligatorio.",
    }),
})
  .unknown(false)
  .messages({
    "object.unknown": "No se permiten propiedades adicionales.",
  });

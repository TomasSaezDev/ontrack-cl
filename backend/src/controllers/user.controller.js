"use strict";
import {
  userBodyValidation,
  userQueryValidation,
} from "../validations/user.validation.js";
import {
  marcadorUpdateValidation,
} from "../validations/marcador.validation.js";
import {
  getUserService,
  getUsersService,
  createUserService,
  updateUserService,
  deleteUserService,
} from "../services/user.service.js";
import {
  getMarcadorByUserService,
  updateMarcadorByUserService,
  getAllMarcadoresService,
} from "../services/marcador.service.js";
import {
  handleErrorClient,
  handleErrorServer,
  handleSuccess,
} from "../handlers/responseHandlers.js";
import Joi from "joi";



export async function getUser(req, res) {
  try {
    const { id, email } = req.query;

    const { error } = userQueryValidation.validate({ id, email });

    if (error) return handleErrorClient(res, 400, error.message);

    const [user, errorUser] = await getUserService({ id, email });

    if (errorUser) return handleErrorClient(res, 404, errorUser);

    handleSuccess(res, 200, "Usuario encontrado", user);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function getUsers(req, res) {
  try {
    const [users, errorUsers] = await getUsersService();

    if (errorUsers) return handleErrorClient(res, 404, errorUsers);

    users.length === 0
      ? handleSuccess(res, 204)
      : handleSuccess(res, 200, "Usuarios encontrados", users);
  } catch (error) {
    handleErrorServer(
      res,
      500,
      error.message,
    );
  }
}

export async function createUser(req, res) {
  try {
    const { body } = req;

    // Validación del body
    const { error: bodyError } = userBodyValidation.validate(body);

    if (bodyError) {
      return handleErrorClient(
        res,
        400,
        "Error de validación en los datos enviados",
        bodyError.message,
      );
    }

    // Verificar que los campos requeridos estén presentes
    if (!body.nombreCompleto || !body.email || !body.rol || !body.password) {
      return handleErrorClient(
        res,
        400,
        "Faltan campos requeridos",
        "nombreCompleto, email, rol y password son obligatorios"
      );
    }

    const [user, userError] = await createUserService(body);

    if (userError) {
      return handleErrorClient(res, 400, "Error al crear usuario", userError);
    }

    handleSuccess(res, 201, "Usuario creado correctamente", user);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function updateUser(req, res) {
  try {
    const { id, email } = req.query;
    const { body } = req;

    const { error: queryError } = userQueryValidation.validate({
      id,
      email,
    });

    if (queryError) {
      return handleErrorClient(
        res,
        400,
        "Error de validación en la consulta",
        queryError.message,
      );
    }

    const { error: bodyError } = userBodyValidation.validate(body);

    if (bodyError)
      return handleErrorClient(
        res,
        400,
        "Error de validación en los datos enviados",
        bodyError.message,
      );

    const [user, userError] = await updateUserService({ id, email }, body);

    if (userError) return handleErrorClient(res, 400, "Error modificando al usuario", userError);

    handleSuccess(res, 200, "Usuario modificado correctamente", user);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function deleteUser(req, res) {
  try {
    const { id, email } = req.query;

    const { error: queryError } = userQueryValidation.validate({
      id,
      email,
    });

    if (queryError) {
      return handleErrorClient(
        res,
        400,
        "Error de validación en la consulta",
        queryError.message,
      );
    }

    const [userDelete, errorUserDelete] = await deleteUserService({
      id,
      email,
    });

    if (errorUserDelete) return handleErrorClient(res, 404, "Error eliminado al usuario", errorUserDelete);

    handleSuccess(res, 200, "Usuario eliminado correctamente", userDelete);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function getMarcador(req, res) {
  try {
    const { id } = req.query;

    const schema = Joi.object({
      id: Joi.number().integer().positive().required().messages({
        "number.base": "El ID del usuario debe ser un número.",
        "number.integer": "El ID del usuario debe ser un número entero.",
        "number.positive": "El ID del usuario debe ser positivo.",
        "any.required": "El ID del usuario es obligatorio.",
      }),
    });

    const { error } = schema.validate({ id: parseInt(id) });

    if (error) return handleErrorClient(res, 400, error.message);

    const [marcador, errorMarcador] = await getMarcadorByUserService(parseInt(id));

    if (errorMarcador) return handleErrorClient(res, 404, errorMarcador);

    handleSuccess(res, 200, "Marcador encontrado", marcador);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function updateMarcador(req, res) {
  try {
    const { id } = req.query;
    const { body } = req;

    const idSchema = Joi.object({
      id: Joi.number().integer().positive().required().messages({
        "number.base": "El ID del usuario debe ser un número.",
        "number.integer": "El ID del usuario debe ser un número entero.",
        "number.positive": "El ID del usuario debe ser positivo.",
        "any.required": "El ID del usuario es obligatorio.",
      }),
    });

    const { error: idError } = idSchema.validate({ id: parseInt(id) });

    if (idError) return handleErrorClient(res, 400, idError.message);

    const { error: bodyError } = marcadorUpdateValidation.validate(body);

    if (bodyError)
      return handleErrorClient(
        res,
        400,
        "Error de validación en los datos enviados",
        bodyError.message,
      );

    const [marcador, errorMarcador] = await updateMarcadorByUserService(parseInt(id), body);

    if (errorMarcador) return handleErrorClient(res, 400, "Error actualizando el marcador", errorMarcador);

    handleSuccess(res, 200, "Marcador actualizado correctamente", marcador);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

export async function getMarcadores(req, res) {
  try {
    const [marcadores, errorMarcadores] = await getAllMarcadoresService();

    if (errorMarcadores) return handleErrorClient(res, 404, errorMarcadores);

    handleSuccess(res, 200, "Marcadores encontrados", marcadores);
  } catch (error) {
    handleErrorServer(res, 500, error.message);
  }
}

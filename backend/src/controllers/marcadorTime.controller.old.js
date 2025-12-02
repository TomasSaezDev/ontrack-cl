"use strict";
import { 
  getAllMarcadores,
  getMarcadorByUserId,
  updateMarcadorTime,
  startGameSession,
  toggleGameSession,
  addTimeToSession,
  resetGameSession,
  endGameSession,
} from "../services/marcadorTime.service.js";
import { handleSuccess, handleErrorClient, handleErrorServer } from "../handlers/responseHandlers.js";

// Obtener todos los marcadores
export async function getMarcadores(req, res) {
  try {
    const [marcadores, error] = await getAllMarcadores();

    if (error) {
      return respondError(req, res, 400, error);
    }

    handleSuccess(res, 200, "Marcadores obtenidos exitosamente", marcadores);
  } catch (error) {
    console.error("Error en getMarcadores:", error);
    respondInternalError(req, res, error);
  }
}

// Obtener marcador por ID de usuario
export async function getMarcadorByUser(req, res) {
  try {
    const { userId } = req.params;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    const [marcador, error] = await getMarcadorByUserId(parseInt(userId));

    if (error) {
      return handleErrorClient(res, 404, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en getMarcadorByUser:", error);
    respondInternalError(req, res, error);
  }
}

// Iniciar sesión de juego
export async function startSession(req, res) {
  try {
    const { userId } = req.params;
    const { timeInMinutes } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (!timeInMinutes || timeInMinutes <= 0) {
      return respondError(req, res, 400, "Tiempo en minutos debe ser mayor a 0");
    }

    const [marcador, error] = await startGameSession(parseInt(userId), timeInMinutes);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en startSession:", error);
    respondInternalError(req, res, error);
  }
}

// Pausar/reanudar sesión
export async function toggleSession(req, res) {
  try {
    const { userId } = req.params;
    const { timeRemaining, isActive, totalTime } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      return respondError(req, res, 400, "Datos de sesión incompletos");
    }

    const currentData = { timeRemaining, isActive, totalTime };
    const [marcador, error] = await toggleGameSession(parseInt(userId), currentData);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en toggleSession:", error);
    respondInternalError(req, res, error);
  }
}

// Agregar tiempo a la sesión
export async function addTime(req, res) {
  try {
    const { userId } = req.params;
    const { additionalMinutes, timeRemaining, isActive, totalTime } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (!additionalMinutes || additionalMinutes <= 0) {
      return respondError(req, res, 400, "Minutos adicionales debe ser mayor a 0");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      return respondError(req, res, 400, "Datos de sesión incompletos");
    }

    const currentData = { timeRemaining, isActive, totalTime };
    const [marcador, error] = await addTimeToSession(parseInt(userId), additionalMinutes, currentData);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en addTime:", error);
    respondInternalError(req, res, error);
  }
}

// Modificar tiempo total
export async function setTime(req, res) {
  try {
    const { userId } = req.params;
    const { totalMinutes } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (totalMinutes === undefined || totalMinutes < 0) {
      return respondError(req, res, 400, "Tiempo total debe ser mayor o igual a 0");
    }

    const totalSeconds = totalMinutes * 60;
    const [marcador, error] = await resetGameSession(parseInt(userId), totalSeconds);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en setTime:", error);
    respondInternalError(req, res, error);
  }
}

// Resetear sesión
export async function resetSession(req, res) {
  try {
    const { userId } = req.params;
    const { totalTime } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (!totalTime || totalTime <= 0) {
      return respondError(req, res, 400, "Tiempo total requerido");
    }

    const [marcador, error] = await resetGameSession(parseInt(userId), totalTime);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en resetSession:", error);
    respondInternalError(req, res, error);
  }
}

// Finalizar sesión
export async function endSession(req, res) {
  try {
    const { userId } = req.params;
    const { totalTime, timeUsed } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (totalTime === undefined || timeUsed === undefined) {
      return respondError(req, res, 400, "Datos de sesión requeridos");
    }

    const sessionData = { totalTime, timeUsed };
    const [marcador, error] = await endGameSession(parseInt(userId), sessionData);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en endSession:", error);
    respondInternalError(req, res, error);
  }
}

// Actualizar tiempo personalizado
export async function updateTime(req, res) {
  try {
    const { userId } = req.params;
    const { timeRemaining, isActive, totalTime } = req.body;

    if (!userId) {
      return respondError(req, res, 400, "ID de usuario requerido");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      return respondError(req, res, 400, "Datos de tiempo requeridos");
    }

    const timeData = { timeRemaining, isActive, totalTime };
    const [marcador, error] = await updateMarcadorTime(parseInt(userId), timeData);

    if (error) {
      return respondError(req, res, 400, error);
    }

    respondSuccess(req, res, 200, marcador);
  } catch (error) {
    console.error("Error en updateTime:", error);
    respondInternalError(req, res, error);
  }
}
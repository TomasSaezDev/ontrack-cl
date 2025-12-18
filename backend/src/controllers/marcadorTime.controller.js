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
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Marcadores obtenidos exitosamente", marcadores);
  } catch (error) {
    console.error("Error en getMarcadores:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Obtener marcador por ID de usuario
export async function getMarcadorByUser(req, res) {
  try {
    const { userId } = req.params;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    const [marcador, error] = await getMarcadorByUserId(parseInt(userId));

    if (error) {
      return handleErrorClient(res, 404, error);
    }

    handleSuccess(res, 200, "Marcador obtenido exitosamente", marcador);
  } catch (error) {
    console.error("Error en getMarcadorByUser:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Iniciar sesión de juego
export async function startSession(req, res) {
  try {
    const { userId } = req.params;
    const { timeInMinutes } = req.body;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (!timeInMinutes || timeInMinutes <= 0) {
      return handleErrorClient(res, 400, "Tiempo en minutos debe ser mayor a 0");
    }

    const [marcador, error] = await startGameSession(parseInt(userId), timeInMinutes);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Sesión iniciada exitosamente", marcador);
  } catch (error) {
    console.error("Error en startSession:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Pausar/reanudar sesión
export async function toggleSession(req, res) {
  try {
    const { userId } = req.params;
    const { timeRemaining, isActive, totalTime } = req.body;

    console.log('🔵 [CONTROLLER] toggleSession iniciado');
    console.log('🔵 [CONTROLLER] userId:', userId);
    console.log('🔵 [CONTROLLER] req.body:', req.body);
    console.log('🔵 [CONTROLLER] timeRemaining:', timeRemaining);
    console.log('🔵 [CONTROLLER] isActive (recibido):', isActive);
    console.log('🔵 [CONTROLLER] totalTime:', totalTime);

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      console.log('❌ [CONTROLLER] Datos de sesión incompletos');
      return handleErrorClient(res, 400, "Datos de sesión incompletos");
    }

    const currentData = { timeRemaining, isActive, totalTime };
    console.log('🔵 [CONTROLLER] currentData:', currentData);
    
    const [marcador, error] = await toggleGameSession(parseInt(userId), currentData);

    if (error) {
      console.log('❌ [CONTROLLER] Error en toggleGameSession:', error);
      return handleErrorClient(res, 400, error);
    }

    console.log('✅ [CONTROLLER] toggleSession exitoso, marcador:', marcador);
    handleSuccess(res, 200, "Estado de sesión actualizado", marcador);
  } catch (error) {
    console.error("❌ [CONTROLLER] Error en toggleSession:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Agregar tiempo a la sesión
export async function addTime(req, res) {
  try {
    const { userId } = req.params;
    const { additionalMinutes, timeRemaining, isActive, totalTime } = req.body;

    console.log(`🎮 addTime controller - userId: ${userId}`);
    console.log(`🎮 req.body:`, req.body);

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (additionalMinutes === undefined || additionalMinutes === 0) {
      return handleErrorClient(res, 400, "Minutos adicionales debe ser diferente de 0");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      return handleErrorClient(res, 400, "Datos de sesión incompletos");
    }

    const currentData = { timeRemaining, isActive, totalTime };
    console.log(`🎮 currentData:`, currentData);
    
    const [marcador, error] = await addTimeToSession(parseInt(userId), additionalMinutes, currentData);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    console.log(`🎮 resultado marcador:`, marcador);
    handleSuccess(res, 200, "Tiempo agregado exitosamente", marcador);
  } catch (error) {
    console.error("Error en addTime:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Modificar tiempo total
export async function setTime(req, res) {
  try {
    const { userId } = req.params;
    const { totalMinutes } = req.body;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (totalMinutes === undefined || totalMinutes < 0) {
      return handleErrorClient(res, 400, "Tiempo total debe ser mayor o igual a 0");
    }

    const totalSeconds = totalMinutes * 60;
    const [marcador, error] = await resetGameSession(parseInt(userId), totalSeconds);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Tiempo establecido exitosamente", marcador);
  } catch (error) {
    console.error("Error en setTime:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Resetear sesión
export async function resetSession(req, res) {
  try {
    const { userId } = req.params;
    const { totalTime } = req.body;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (!totalTime || totalTime <= 0) {
      return handleErrorClient(res, 400, "Tiempo total requerido");
    }

    const [marcador, error] = await resetGameSession(parseInt(userId), totalTime);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Sesión reiniciada exitosamente", marcador);
  } catch (error) {
    console.error("Error en resetSession:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Finalizar sesión
export async function endSession(req, res) {
  try {
    const { userId } = req.params;
    const { totalTime, timeUsed } = req.body;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (totalTime === undefined || timeUsed === undefined) {
      return handleErrorClient(res, 400, "Datos de sesión requeridos");
    }

    const sessionData = { totalTime, timeUsed };
    const [marcador, error] = await endGameSession(parseInt(userId), sessionData);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Sesión finalizada exitosamente", marcador);
  } catch (error) {
    console.error("Error en endSession:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}

// Actualizar tiempo personalizado
export async function updateTime(req, res) {
  try {
    const { userId } = req.params;
    const { timeRemaining, isActive, totalTime } = req.body;

    if (!userId) {
      return handleErrorClient(res, 400, "ID de usuario requerido");
    }

    if (timeRemaining === undefined || isActive === undefined || totalTime === undefined) {
      return handleErrorClient(res, 400, "Datos de tiempo requeridos");
    }

    const timeData = { timeRemaining, isActive, totalTime };
    const [marcador, error] = await updateMarcadorTime(parseInt(userId), timeData);

    if (error) {
      return handleErrorClient(res, 400, error);
    }

    handleSuccess(res, 200, "Tiempo actualizado exitosamente", marcador);
  } catch (error) {
    console.error("Error en updateTime:", error);
    handleErrorServer(res, 500, "Error interno del servidor");
  }
}
"use strict";
import Marcador from "../entity/marcador.entity.js";
import MarcadorTime from "../entity/marcadorTime.entity.js";
import User from "../entity/user.entity.js";
import { AppDataSource } from "../config/configDb.js";

// Función helper para calcular tiempo restante real
function calculateRealTimeRemaining(marcadorTime) {
  if (!marcadorTime.isActive) {
    // Si está pausado, devolver el tiempo guardado
    return marcadorTime.timeRemaining;
  }

  // Si está activo, calcular el tiempo transcurrido desde que se inició
  if (!marcadorTime.sessionStartTime) {
    return marcadorTime.timeRemaining;
  }

  const now = new Date();
  const sessionStart = new Date(marcadorTime.sessionStartTime);
  const elapsedSeconds = Math.floor((now - sessionStart) / 1000);
  const realTimeRemaining = Math.max(0, marcadorTime.timeRemaining - elapsedSeconds);

  return realTimeRemaining;
}

// Obtener todos los marcadores con información de usuarios
async function getAllMarcadores() {
  try {
    const marcadorRepository = AppDataSource.getRepository(Marcador);
    const marcadorTimeRepository = AppDataSource.getRepository(MarcadorTime);
    
    const marcadores = await marcadorRepository.find({
      relations: ["user"],
      order: {
        id: "ASC"
      }
    });

    // Obtener datos de tiempo real de MarcadorTime
    const marcadoresConTiempo = [];
    for (const marcador of marcadores) {
      let marcadorTime = await marcadorTimeRepository.findOne({
        where: { userId: marcador.userId },
        relations: ["user"]
      });

      // Si no existe registro de tiempo, crear uno por defecto
      if (!marcadorTime) {
        marcadorTime = marcadorTimeRepository.create({
          userId: marcador.userId,
          timeRemaining: 0,
          totalTime: 0, // Empezar en 0, el admin debe agregar tiempo
          isActive: false,
          sessionStartTime: null,
          lastPauseTime: null,
          totalSessionTime: 0,
          sessionsCount: 0
        });
        await marcadorTimeRepository.save(marcadorTime);
      }

      // Calcular tiempo real si está activo
      const realTimeRemaining = calculateRealTimeRemaining(marcadorTime);

      // Si el tiempo llegó a 0 y está activo, pausar automáticamente
      if (realTimeRemaining === 0 && marcadorTime.isActive) {
        marcadorTime.isActive = false;
        marcadorTime.timeRemaining = 0;
        marcadorTime.sessionStartTime = null;
        marcadorTime.lastPauseTime = new Date();
        await marcadorTimeRepository.save(marcadorTime);
      }

      marcadoresConTiempo.push({
        ...marcador,
        timeRemaining: realTimeRemaining,
        isActive: marcadorTime.isActive,
        totalTime: marcadorTime.totalTime,
      });
    }

    return [marcadoresConTiempo, null];
  } catch (error) {
    console.error("Error al obtener marcadores:", error);
    return [null, "Error interno del servidor"];
  }
}

// Obtener marcador por ID de usuario
async function getMarcadorByUserId(userId) {
  try {
    const marcadorRepository = AppDataSource.getRepository(Marcador);
    const marcadorTimeRepository = AppDataSource.getRepository(MarcadorTime);
    
    const marcador = await marcadorRepository.findOne({
      where: { user: { id: userId } },
      relations: ["user"]
    });

    if (!marcador) {
      return [null, "Marcador no encontrado"];
    }

    // Obtener datos de tiempo real
    let marcadorTime = await marcadorTimeRepository.findOne({
      where: { userId: userId }
    });

    // Si no existe registro de tiempo, crear uno por defecto
    if (!marcadorTime) {
      marcadorTime = marcadorTimeRepository.create({
        userId: userId,
        timeRemaining: 0,
        totalTime: 0,
        isActive: false,
        sessionStartTime: null,
        lastPauseTime: null,
        totalSessionTime: 0,
        sessionsCount: 0
      });
      await marcadorTimeRepository.save(marcadorTime);
    }

    // Calcular tiempo real si está activo
    const realTimeRemaining = calculateRealTimeRemaining(marcadorTime);

    // Si el tiempo llegó a 0 y está activo, pausar automáticamente
    if (realTimeRemaining === 0 && marcadorTime.isActive) {
      marcadorTime.isActive = false;
      marcadorTime.timeRemaining = 0;
      marcadorTime.sessionStartTime = null;
      marcadorTime.lastPauseTime = new Date();
      await marcadorTimeRepository.save(marcadorTime);
    }

    const marcadorConTiempo = {
      ...marcador,
      timeRemaining: realTimeRemaining,
      isActive: marcadorTime.isActive,
      totalTime: marcadorTime.totalTime,
    };

    return [marcadorConTiempo, null];
  } catch (error) {
    console.error("Error al obtener marcador por userId:", error);
    return [null, "Error interno del servidor"];
  }
}

// Actualizar tiempo de marcador
async function updateMarcadorTime(userId, timeData) {
  try {
    const { timeRemaining, isActive, totalTime } = timeData;
    
    console.log('🔧 [SERVICE] updateMarcadorTime iniciado');
    console.log('🔧 [SERVICE] userId:', userId);
    console.log('🔧 [SERVICE] timeData:', timeData);
    
    // Validaciones
    if (timeRemaining < 0) {
      console.log('❌ [SERVICE] timeRemaining negativo:', timeRemaining);
      return [null, "El tiempo restante no puede ser negativo"];
    }
    
    if (totalTime < 0) {
      console.log('❌ [SERVICE] totalTime negativo:', totalTime);
      return [null, "El tiempo total no puede ser negativo"];
    }

    const marcadorRepository = AppDataSource.getRepository(Marcador);
    const marcadorTimeRepository = AppDataSource.getRepository(MarcadorTime);
    
    // Buscar el marcador
    const marcador = await marcadorRepository.findOne({
      where: { user: { id: userId } },
      relations: ["user"]
    });

    if (!marcador) {
      return [null, "Marcador no encontrado"];
    }

    // Buscar o crear registro de MarcadorTime
    let marcadorTime = await marcadorTimeRepository.findOne({
      where: { userId: userId }
    });

    if (!marcadorTime) {
      marcadorTime = marcadorTimeRepository.create({
        userId: userId,
        timeRemaining: 0,
        totalTime: 0,
        isActive: false,
        sessionStartTime: null,
        lastPauseTime: null,
        totalSessionTime: 0,
        sessionsCount: 0
      });
    }

    // Actualizar datos de tiempo
    console.log('🔧 [SERVICE] Estado anterior isActive:', marcadorTime.isActive);
    console.log('🔧 [SERVICE] Nuevo estado isActive:', isActive);
    console.log('🔧 [SERVICE] timeRemaining recibido:', timeRemaining);
    
    const wasActive = marcadorTime.isActive;
    
    // Manejar timestamps de sesión ANTES de actualizar
    if (isActive && !wasActive) {
      // Iniciando o reanudando sesión
      console.log('▶️ [SERVICE] Iniciando/reanudando sesión');
      console.log('▶️ [SERVICE] Usando timeRemaining:', timeRemaining);
      marcadorTime.sessionStartTime = new Date();
      marcadorTime.lastPauseTime = null;
      marcadorTime.timeRemaining = timeRemaining; // Usar el tiempo recibido
    } else if (!isActive && wasActive) {
      // Pausando sesión - usar el tiempo calculado por el frontend
      console.log('⏸️ [SERVICE] Pausando sesión');
      console.log('⏸️ [SERVICE] Guardando timeRemaining del frontend:', timeRemaining);
      marcadorTime.timeRemaining = timeRemaining; // Usar el tiempo calculado del frontend
      marcadorTime.lastPauseTime = new Date();
      marcadorTime.sessionStartTime = null;
    } else {
      // Actualización sin cambio de estado
      console.log('🔄 [SERVICE] Actualización sin cambio de estado');
      marcadorTime.timeRemaining = timeRemaining;
    }
    
    marcadorTime.isActive = isActive;
    marcadorTime.totalTime = totalTime;
    marcadorTime.updatedAt = new Date();

    console.log('🔧 [SERVICE] Guardando marcadorTime en BD...');
    console.log('🔧 [SERVICE] Datos finales a guardar:');
    console.log('🔧 [SERVICE]   - isActive: ' + marcadorTime.isActive);
    console.log('🔧 [SERVICE]   - timeRemaining: ' + marcadorTime.timeRemaining);
    console.log('🔧 [SERVICE]   - totalTime: ' + marcadorTime.totalTime);
    console.log('🔧 [SERVICE]   - sessionStartTime: ' + marcadorTime.sessionStartTime);
    
    await marcadorTimeRepository.save(marcadorTime);
    
    console.log('✅ [SERVICE] marcadorTime guardado EXITOSAMENTE en BD');

    // Actualizar estadísticas permanentes si se completa una sesión
    if (timeRemaining === 0 && isActive === false && totalTime > 0) {
      const puntosGanados = Math.floor(totalTime / 600); // 1 punto cada 10 minutos
      marcador.puntos += puntosGanados;
      marcador.horas += Math.floor(totalTime / 3600);
      
      await marcadorRepository.save(marcador);
    }

    const marcadorActualizado = {
      ...marcador,
      timeRemaining: marcadorTime.timeRemaining,
      isActive: marcadorTime.isActive,
      totalTime: marcadorTime.totalTime,
    };

    return [marcadorActualizado, null];
  } catch (error) {
    console.error("Error al actualizar tiempo de marcador:", error);
    return [null, "Error interno del servidor"];
  }
}

// Iniciar sesión de juego
async function startGameSession(userId, timeInMinutes) {
  try {
    const timeInSeconds = timeInMinutes * 60;
    
    const timeData = {
      timeRemaining: timeInSeconds,
      isActive: true,
      totalTime: timeInSeconds,
    };
    
    return await updateMarcadorTime(userId, timeData);
  } catch (error) {
    console.error("Error al iniciar sesión de juego:", error);
    return [null, "Error interno del servidor"];
  }
}

// Pausar/reanudar sesión de juego
async function toggleGameSession(userId, currentData) {
  try {
    const { timeRemaining, isActive, totalTime } = currentData;
    
    console.log('\n🔧🔧🔧 [BACKEND toggleGameSession] ============ RECIBIDO DEL FRONTEND ============');
    console.log(`🔧 [BACKEND] userId: ${userId}`);
    console.log(`🔧 [BACKEND] timeRemaining recibido: ${timeRemaining}`);
    console.log(`🔧 [BACKEND] isActive recibido (NUEVO estado): ${isActive}`);
    console.log(`🔧 [BACKEND] totalTime recibido: ${totalTime}`);
    console.log(`🔧 [BACKEND] Acción: ${isActive ? 'REANUDAR' : 'PAUSAR'}`);
    
    // El isActive recibido YA ES el nuevo estado deseado
    // NO lo invertimos aquí porque el frontend ya lo hizo
    const timeData = {
      timeRemaining,
      isActive, // Guardar directamente el estado recibido
      totalTime,
    };
    
    console.log(`🔧 [BACKEND] timeData que se pasará a updateMarcadorTime:`, timeData);
    
    return await updateMarcadorTime(userId, timeData);
  } catch (error) {
    console.error("Error al pausar/reanudar sesión:", error);
    return [null, "Error interno del servidor"];
  }
}

// Agregar tiempo a sesión activa
async function addTimeToSession(userId, additionalMinutes, currentData) {
  try {
    const additionalSeconds = additionalMinutes * 60;
    const { timeRemaining, isActive, totalTime } = currentData;
    
    console.log(`🔧 addTimeToSession - userId: ${userId}, additionalMinutes: ${additionalMinutes}`);
    console.log(`🔧 currentData:`, currentData);
    console.log(`🔧 additionalSeconds: ${additionalSeconds}, timeRemaining: ${timeRemaining}, totalTime: ${totalTime}`);
    
    const newTimeRemaining = timeRemaining + additionalSeconds;
    const newTotalTime = totalTime + additionalSeconds;
    
    console.log(`🔧 newTimeRemaining: ${newTimeRemaining}, newTotalTime: ${newTotalTime}`);
    
    // Validar que no se quede en valores negativos
    if (newTimeRemaining < 0 || newTotalTime < 0) {
      console.log('❌ [SERVICE] No se puede quitar más tiempo del disponible');
      return [null, "No se puede quitar más tiempo del disponible"];
    }
    
    const timeData = {
      timeRemaining: newTimeRemaining,
      isActive,
      totalTime: newTotalTime,
    };
    
    console.log(`🔧 timeData to save:`, timeData);
    
    return await updateMarcadorTime(userId, timeData);
  } catch (error) {
    console.error("Error al agregar tiempo:", error);
    return [null, "Error interno del servidor"];
  }
}

// Resetear sesión de juego
async function resetGameSession(userId, totalTime) {
  try {
    const timeData = {
      timeRemaining: totalTime,
      isActive: false,
      totalTime,
    };
    
    return await updateMarcadorTime(userId, timeData);
  } catch (error) {
    console.error("Error al resetear sesión:", error);
    return [null, "Error interno del servidor"];
  }
}

// Finalizar sesión de juego y actualizar estadísticas
async function endGameSession(userId, sessionData) {
  try {
    const { totalTime, timeUsed } = sessionData;
    
    const marcadorRepository = AppDataSource.getRepository(Marcador);
    
    const marcador = await marcadorRepository.findOne({
      where: { user: { id: userId } },
      relations: ["user"]
    });

    if (!marcador) {
      return [null, "Marcador no encontrado"];
    }

    // Actualizar estadísticas
    const horasJugadas = timeUsed / 3600;
    const puntosGanados = Math.floor(timeUsed / 600); // 1 punto cada 10 minutos
    
    marcador.horas += horasJugadas;
    marcador.puntos += puntosGanados;
    marcador.visitas += 1;

    await marcadorRepository.save(marcador);

    const marcadorActualizado = {
      ...marcador,
      timeRemaining: 0,
      isActive: false,
      totalTime: 0,
    };

    return [marcadorActualizado, null];
  } catch (error) {
    console.error("Error al finalizar sesión de juego:", error);
    return [null, "Error interno del servidor"];
  }
}

export {
  getAllMarcadores,
  getMarcadorByUserId,
  updateMarcadorTime,
  startGameSession,
  toggleGameSession,
  addTimeToSession,
  resetGameSession,
  endGameSession,
};
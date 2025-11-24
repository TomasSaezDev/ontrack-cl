"use strict";
import Marcador from "../entity/marcador.entity.js";
import { AppDataSource } from "../config/configDb.js";

export async function getMarcadorByUserService(userId) {
  try {
    const marcadorRepository = AppDataSource.getRepository(Marcador);

    const marcadorFound = await marcadorRepository.findOne({
      where: { user: { id: userId } },
      relations: ["user"],
    });

    if (!marcadorFound) return [null, "Marcador no encontrado"];

    // Remover información sensible del usuario
    const { user, ...marcadorData } = marcadorFound;
    const { password, ...userData } = user;

    return [{ ...marcadorData, user: userData }, null];
  } catch (error) {
    console.error("Error al obtener el marcador:", error);
    return [null, "Error interno del servidor"];
  }
}

export async function updateMarcadorByUserService(userId, body) {
  try {
    const marcadorRepository = AppDataSource.getRepository(Marcador);

    const marcadorFound = await marcadorRepository.findOne({
      where: { user: { id: userId } },
    });

    if (!marcadorFound) return [null, "Marcador no encontrado"];

    const dataToUpdate = {
      updatedAt: new Date(),
    };

    if (body.visitas !== undefined) dataToUpdate.visitas = body.visitas;
    if (body.horas !== undefined) dataToUpdate.horas = body.horas;
    if (body.puntos !== undefined) dataToUpdate.puntos = body.puntos;

    await marcadorRepository.update({ id: marcadorFound.id }, dataToUpdate);

    const updatedMarcador = await marcadorRepository.findOne({
      where: { id: marcadorFound.id },
    });

    if (!updatedMarcador) {
      return [null, "Marcador no encontrado después de actualizar"];
    }

    return [updatedMarcador, null];
  } catch (error) {
    console.error("Error al actualizar el marcador:", error);
    return [null, "Error interno del servidor"];
  }
}

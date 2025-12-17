"use strict";
import { AppDataSource } from "../config/configDb.js";
import TorneoSchema from "../entity/torneo.entity.js";
import UserSchema from "../entity/user.entity.js";
import TorneoRegistroSchema from "../entity/torneoRegistro.entity.js";

export async function createTorneo(data) {
    try {
        const torneoRepository = AppDataSource.getRepository(TorneoSchema);
        const newTorneo = torneoRepository.create(data);
        const savedTorneo = await torneoRepository.save(newTorneo);
        return [savedTorneo, null];
    } catch (error) {
        console.error("Error al crear torneo:", error);
        return [null, "Error interno del servidor"];
    }
}

export async function getTorneos() {
    try {
        const torneoRepository = AppDataSource.getRepository(TorneoSchema);
        const torneos = await torneoRepository.find({
            order: {
                createdAt: "DESC",
            },
        });
        return [torneos, null];
    } catch (error) {
        console.error("Error al obtener torneos:", error);
        return [null, "Error interno del servidor"];
    }
}

export async function getTorneoById(id) {
    try {
        const torneoRepository = AppDataSource.getRepository(TorneoSchema);
        const torneoRegistroRepository = AppDataSource.getRepository(TorneoRegistroSchema);

        const torneo = await torneoRepository.findOne({ where: { id } });

        if (!torneo) {
            return [null, "Torneo no encontrado"];
        }

        const participantes = await torneoRegistroRepository.find({
            where: { torneoId: id },
            relations: ["user"], // Cargar la relación con User
        });

        // Formatear la respuesta para incluir los participantes dentro del objeto torneo
        const torneoConParticipantes = {
            ...torneo,
            participants: participantes.map(p => ({
                userId: p.userId,
                nombreCompleto: p.user.nombreCompleto,
                email: p.user.email,
                puntajeObtenido: p.puntajeObtenido,
                registroId: p.id
            }))
        };

        return [torneoConParticipantes, null];

    } catch (error) {
        console.error("Error al obtener torneo por ID:", error);
        return [null, "Error interno del servidor"];
    }
}

export async function addParticipant(torneoId, userId) {
    try {
        const torneoRepository = AppDataSource.getRepository(TorneoSchema);
        const userRepository = AppDataSource.getRepository(UserSchema);
        const torneoRegistroRepository = AppDataSource.getRepository(TorneoRegistroSchema);

        const torneo = await torneoRepository.findOne({ where: { id: torneoId } });
        if (!torneo) return [null, "Torneo no encontrado"];

        const user = await userRepository.findOne({ where: { id: userId } });
        if (!user) return [null, "Usuario no encontrado"];

        const existingRegistro = await torneoRegistroRepository.findOne({
            where: { torneoId, userId },
        });
        if (existingRegistro) return [null, "El usuario ya está inscrito en este torneo"];

        const newRegistro = torneoRegistroRepository.create({
            torneoId,
            userId,
            puntajeObtenido: 0,
        });

        const savedRegistro = await torneoRegistroRepository.save(newRegistro);
        return [savedRegistro, null];
    } catch (error) {
        console.error("Error al inscribir usuario:", error);
        return [null, "Error interno del servidor"];
    }
}

"use strict";

import { EntitySchema } from "typeorm";

const TorneoRegistroSchema = new EntitySchema({
    name: "TorneoRegistro",
    tableName: "torneo_registros",
    columns: {
        id: {
            type: "int",
            primary: true,
            generated: true,
        },
        torneoId: {
            type: "int",
            nullable: false,
        },
        userId: {
            type: "int",
            nullable: false,
        },
        puntajeObtenido: {
            type: "int",
            nullable: false,
        },
        createdAt: {
            type: "timestamp with time zone",
            default: () => "CURRENT_TIMESTAMP",
            nullable: false,
        },
        updatedAt: {
            type: "timestamp with time zone",
            default: () => "CURRENT_TIMESTAMP",
            onUpdate: "CURRENT_TIMESTAMP",
            nullable: false,
        },
    },
    relations: {
        torneo: {
            type: "one-to-one",
            target: "Torneo",
            joinColumn: {
                name: "torneoId",
                referencedColumnName: "id",
            },
            onDelete: "CASCADE",
        },
        user: {
            type: "one-to-one",
            target: "User",
            joinColumn: {
                name: "userId",
                referencedColumnName: "id",
            },
            onDelete: "CASCADE",
        },
    },
    indices: [
        {
            name: "IDX_TORNEO_REGISTRO",
            columns: ["id"],
            unique: true,
        },
        {
            name: "IDX_TORNEO_REGISTRO_TORNEO",
            columns: ["torneoId"],
            unique: true,
        },
        {
            name: "IDX_TORNEO_REGISTRO_USER",
            columns: ["userId"],
            unique: true,
        },
    ],
});
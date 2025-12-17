"use strict";
import { EntitySchema } from "typeorm";

const TorneoSchema = new EntitySchema({
    name: "Torneo",
    tableName: "torneos",
    columns: {
        id: {
            type: "int",
            primary: true,
            generated: true,
        },
        nombre: {
            type: "varchar",
            length: 255,
            nullable: false,
        },
        fechaInicio: {
            type: "timestamp with time zone",
            nullable: false,
        },
        descripcion: {
            type: "text",
            nullable: true,
        },
        premio: {
            type: "int",
            nullable: false,
            default: 0,
        },
        estado: {
            type: "boolean",
            default: true,
            nullable: false,
        },
        userId: {
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
            name: "IDX_TORNEO",
            columns: ["id"],
            unique: true,
        },
        {
            name: "IDX_TORNEO_USER",
            columns: ["userId"],
            unique: true,
        },
    ],
});

export default TorneoSchema;
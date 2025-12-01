"use strict";

import { EntitySchema } from "typeorm";

const ScoreLogSchema = new EntitySchema({
    name: "ScoreLog",
    tableName: "score_logs",
    columns: {
        id: {
            type: "int",
            primary: true,
            generated: true,
        },
        userId: {
            type: "int",
            nullable: false,
        },
        puntaje: {
            type: "int",
            nullable: false,
        },
        descripcion: {
            type: "text",
            nullable: true,
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
            name: "IDX_SCORE_LOG",
            columns: ["id"],
            unique: true,
        },
        {
            name: "IDX_SCORE_LOG_USER",
            columns: ["userId"],
            unique: true,
        },
    ],
});

export default ScoreLogSchema;

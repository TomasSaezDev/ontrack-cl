"use strict";
import { EntitySchema } from "typeorm";

const MarcadorTimeSchema = new EntitySchema({
  name: "MarcadorTime",
  tableName: "marcador_times",
  columns: {
    id: {
      type: "int",
      primary: true,
      generated: true,
    },
    userId: {
      type: "int",
      nullable: false,
      unique: true,
    },
    timeRemaining: {
      type: "int",
      nullable: false,
      default: 0,
      comment: "Tiempo restante en segundos",
    },
    totalTime: {
      type: "int",
      nullable: false,
      default: 0,
      comment: "Tiempo total asignado en segundos",
    },
    isActive: {
      type: "boolean",
      nullable: false,
      default: false,
      comment: "Si la sesión está activa",
    },
    sessionStartTime: {
      type: "timestamp with time zone",
      nullable: true,
      comment: "Momento cuando se inició la sesión actual",
    },
    lastPauseTime: {
      type: "timestamp with time zone",
      nullable: true,
      comment: "Momento cuando se pausó la sesión",
    },
    totalSessionTime: {
      type: "int",
      nullable: false,
      default: 0,
      comment: "Tiempo total de sesiones en segundos",
    },
    sessionsCount: {
      type: "int",
      nullable: false,
      default: 0,
      comment: "Número total de sesiones",
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
      name: "IDX_MARCADOR_TIME",
      columns: ["id"],
      unique: true,
    },
    {
      name: "IDX_MARCADOR_TIME_USER",
      columns: ["userId"],
      unique: true,
    },
  ],
});

export default MarcadorTimeSchema;
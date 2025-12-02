"use strict";
import { EntitySchema } from "typeorm";

const RecompensaSchema = new EntitySchema({
  name: "Recompensa",
  tableName: "recompensas",
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
    costoEnPuntos: {
      type: "int",
      nullable: false,
    },
    activo: {
      type: "boolean",
      default: true,
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
  indices: [
    {
      name: "IDX_RECOMPENSA",
      columns: ["id"],
      unique: true,
    },
    {
      name: "IDX_RECOMPENSA_ACTIVO",
      columns: ["activo"],
    },
  ],
});

export default RecompensaSchema;

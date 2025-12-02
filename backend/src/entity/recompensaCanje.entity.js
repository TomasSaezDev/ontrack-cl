"use strict";
import { EntitySchema } from "typeorm";

const RecompensaCanjeSchema = new EntitySchema({
  name: "RecompensaCanje",
  tableName: "recompensa_canjes",
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
    recompensaId: {
      type: "int",
      nullable: false,
    },
    puntosGastados: {
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
      type: "many-to-one",
      target: "User",
      joinColumn: {
        name: "userId",
        referencedColumnName: "id",
      },
      onDelete: "CASCADE",
    },
    recompensa: {
      type: "many-to-one",
      target: "Recompensa",
      joinColumn: {
        name: "recompensaId",
        referencedColumnName: "id",
      },
      onDelete: "CASCADE",
    },
  },
  indices: [
    {
      name: "IDX_RECOMPENSA_CANJE",
      columns: ["id"],
      unique: true,
    },
    {
      name: "IDX_RECOMPENSA_CANJE_USER",
      columns: ["userId"],
    },
    {
      name: "IDX_RECOMPENSA_CANJE_RECOMPENSA",
      columns: ["recompensaId"],
    },
  ],
});

export default RecompensaCanjeSchema;

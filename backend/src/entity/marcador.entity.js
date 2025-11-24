"use strict";
import { EntitySchema } from "typeorm";

const MarcadorSchema = new EntitySchema({
  name: "Marcador",
  tableName: "marcadores",
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
    visitas: {
      type: "int",
      nullable: false,
      default: 0,
    },
    horas: {
      type: "int",
      nullable: false,
      default: 0,
    },
    puntos: {
      type: "int",
      nullable: false,
      default: 0,
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
      name: "IDX_MARCADOR",
      columns: ["id"],
      unique: true,
    },
    {
      name: "IDX_MARCADOR_USER",
      columns: ["userId"],
      unique: true,
    },
  ],
});

export default MarcadorSchema;

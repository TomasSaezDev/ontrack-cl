"use strict";
import User from "../entity/user.entity.js";
import Marcador from "../entity/marcador.entity.js";
import { AppDataSource } from "./configDb.js";
import { encryptPassword } from "../helpers/bcrypt.helper.js";

async function createUsers() {
  try {
    const userRepository = AppDataSource.getRepository(User);
    const marcadorRepository = AppDataSource.getRepository(Marcador);

    const count = await userRepository.count();
    if (count > 0) return;

    const users = await Promise.all([
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Tomás Sáez Aguayo",
          email: "tomass2942@gmail.com",
          password: await encryptPassword("admin1234"),
          rol: "administrador",
        }),
      ),
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Diego Sebastián Ampuero Belmar",
          email: "usuario1.2024@gmail.cl",
          password: await encryptPassword("user1234"),
          rol: "usuario",
        })
      ),
        userRepository.save(
          userRepository.create({
            nombreCompleto: "Alexander Benjamín Marcelo Carrasco Fuentes",
            email: "usuario2.2024@gmail.cl",
            password: await encryptPassword("user1234"),
            rol: "usuario",
          }),
      ),
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Pablo Andrés Castillo Fernández",
          email: "usuario3.2024@gmail.cl",
          password: await encryptPassword("user1234"),
          rol: "usuario",
        }),
      ),
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Felipe Andrés Henríquez Zapata",
          email: "usuario4.2024@gmail.cl",
          password: await encryptPassword("user1234"),
          rol: "usuario",
        }),
      ),
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Diego Alexis Meza Ortega",
          email: "usuario5.2024@gmail.cl",
          password: await encryptPassword("user1234"),
          rol: "usuario",
        }),
      ),
      userRepository.save(
        userRepository.create({
          nombreCompleto: "Juan Pablo Rosas Martin",
          email: "usuario6.2024@gmail.cl",
          password: await encryptPassword("user1234"),
          rol: "usuario",
        }),
      ),
    ]);
    console.log("* => Usuarios creados exitosamente");

    // Crear marcadores vacíos para todos los usuarios
    await Promise.all(
      users.map((user) =>
        marcadorRepository.save(
          marcadorRepository.create({
            visitas: 0,
            horas: 0,
            puntos: 0,
            user: user,
          })
        )
      )
    );
    console.log("* => Marcadores creados exitosamente para todos los usuarios");
  } catch (error) {
    console.error("Error al crear usuarios:", error);
  }
}

export { createUsers };
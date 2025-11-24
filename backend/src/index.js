"use strict";
import cors from "cors"; // Manejar peticiones de origen cruzado
import morgan from "morgan"; // Registrar solicitudes HTTP
import cookieParser from "cookie-parser"; // Analizar cookies en las solicitudes
import indexRoutes from "./routes/index.routes.js"; // Rutas principales
import session from "express-session"; // Gestionar sesiones de usuario
import passport from "passport"; // Autenticación basada en JWT
import express, { json, urlencoded } from "express"; // parsear JSON y URL codificada
import { cookieKey, HOST, PORT } from "./config/configEnv.js"; // variables de entorno
import { connectDB } from "./config/configDb.js"; // conexión a la base de datos
import { createUsers } from "./config/initialSetup.js";
import { passportJwtSetup } from "./auth/passport.auth.js"; // configuración de Passport

async function setupServer() {
  try {
    const app = express();

    app.disable("x-powered-by");

    app.use(
      cors({
        credentials: true,
        origin: true,
      }),
    );

    app.use(
      urlencoded({
        extended: true,
        limit: "1mb",
      }),
    );

    app.use(
      json({
        limit: "1mb",
      }),
    );

    app.use(cookieParser());

    app.use(morgan("dev"));

    app.use(
      session({
        secret: cookieKey,
        resave: false,
        saveUninitialized: false,
        cookie: {
          secure: false,
          httpOnly: true,
          sameSite: "strict",
        },
      }),
    );

    app.use(passport.initialize());
    app.use(passport.session());

    passportJwtSetup();

    app.use("/api", indexRoutes);

    app.listen(PORT, () => {
      console.log(`=> Servidor corriendo en ${HOST}:${PORT}/api`);
    });
  } catch (error) {
    console.log("Error en index.js -> setupServer(), el error es: ", error);
  }
}

async function setupAPI() {
  try {
    await connectDB();
    await setupServer();
    await createUsers();
  } catch (error) {
    console.log("Error en index.js -> setupAPI(), el error es: ", error);
  }
}

setupAPI()
  .then(() => console.log("=> API Iniciada exitosamente"))
  .catch((error) =>
    console.log("Error en index.js -> setupAPI(), el error es: ", error),
  );
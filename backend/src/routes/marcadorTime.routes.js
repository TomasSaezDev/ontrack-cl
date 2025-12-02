"use strict";
import { Router } from "express";
import { 
  getMarcadores,
  getMarcadorByUser,
  startSession,
  toggleSession,
  addTime,
  setTime,
  resetSession,
  endSession,
  updateTime,
} from "../controllers/marcadorTime.controller.js";
import { authenticateJwt } from "../middlewares/authentication.middleware.js";
import { isAdmin } from "../middlewares/authorization.middleware.js";

const router = Router();

// Endpoint de prueba sin autenticación
router.get("/test", (req, res) => {
  res.json({
    status: "Success",
    message: "Conexión al servidor de marcadores exitosa",
    data: {
      timestamp: new Date().toISOString(),
      server: "marcadorTime API",
    },
  });
});

// Rutas para administradores
router
  .use(authenticateJwt)
  .use(isAdmin);

// Obtener todos los marcadores
router.get("/", getMarcadores);

// Obtener marcador por usuario
router.get("/user/:userId", getMarcadorByUser);

// Gestión de sesiones de juego
router.post("/user/:userId/start", startSession);
router.patch("/user/:userId/toggle", toggleSession);
router.patch("/user/:userId/add-time", addTime);
router.patch("/user/:userId/set-time", setTime);
router.patch("/user/:userId/reset", resetSession);
router.patch("/user/:userId/end", endSession);
router.patch("/user/:userId/update", updateTime);

export default router;
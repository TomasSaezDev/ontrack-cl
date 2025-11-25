"use strict";
import { Router } from "express";
import { isAdmin } from "../middlewares/authorization.middleware.js";
import { authenticateJwt } from "../middlewares/authentication.middleware.js";
import {
  deleteUser,
  getMarcador,
  getUser,
  getUsers,
  updateMarcador,
  updateUser,
  getMarcadores,
} from "../controllers/user.controller.js";

const router = Router();

router.use(authenticateJwt);

router.get("/marcadores", getMarcadores);
router.get("/detail/marcador", getMarcador);

router.use(isAdmin);

router
  .get("/", getUsers)
  .get("/detail/", getUser)
  .patch("/detail/", updateUser)
  .delete("/detail/", deleteUser)
  .patch("/detail/marcador", updateMarcador);

export default router;
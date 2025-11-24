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
} from "../controllers/user.controller.js";

const router = Router();

router
  .use(authenticateJwt)
  .use(isAdmin);

router
  .get("/", getUsers)
  .get("/detail/", getUser)
  .patch("/detail/", updateUser)
  .delete("/detail/", deleteUser)
  .get("/detail/marcador", getMarcador)
  .patch("/detail/marcador", updateMarcador);

export default router;
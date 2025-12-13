"use strict";
import { Router } from "express";
import {
    addParticipantController,
    createTorneoController,
    getTorneoByIdController,
    getTorneosController,
} from "../controllers/torneo.controller.js";
import { authenticateJwt } from "../middlewares/authentication.middleware.js";
import { isAdmin } from "../middlewares/authorization.middleware.js";

const router = Router();

router.use(authenticateJwt);

router.post("/", isAdmin, createTorneoController);
router.post("/:id/inscribir", isAdmin, addParticipantController);
router.get("/", getTorneosController);
router.get("/:id", getTorneoByIdController);

export default router;

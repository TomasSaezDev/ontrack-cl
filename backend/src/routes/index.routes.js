"use strict";
import { Router } from "express";
import userRoutes from "./user.routes.js";
import authRoutes from "./auth.routes.js";
import marcadorTimeRoutes from "./marcadorTime.routes.js";
import torneoRoutes from "./torneo.routes.js";

const router = Router();

router
    .use("/auth", authRoutes)
    .use("/user", userRoutes)
    .use("/marcadores", marcadorTimeRoutes)
    .use("/torneos", torneoRoutes);

export default router;
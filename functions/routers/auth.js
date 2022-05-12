const express = require("express"),
    app = express(),
    functions = require("firebase-functions")
    authController = require("../controllers/auth_controller");

app.post("/sign/:action", authController.sign);
app.post("/saveUserInfo", authController.saveUserInfo);
app.post("/autoAuth", authController.autoAuth);
app.post("/refreshToken", authController.refreshToken);

exports.auth = functions.https.onRequest(app);

const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    userController = require("../controllers/user_controller");
 
app.post("/checkDeviceToken", userController.checkDeviceToken);
app.post("/saveDeviceToken", userController.saveDeviceToken);
app.post("/deleteDeviceToken", userController.deleteDeviceToken);
app.post("/setNotifications", userController.setNotification);
app.post("/follow", userController.follow);
app.get("/getInfo/:userUid", userController.getUserInfo);

exports.user = functions.https.onRequest(app);

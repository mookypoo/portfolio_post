const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    photosController = require("../controllers/photos_controller");
    
app.get("/get/:postUid", photosController.getPhoto);
app.post("/upload", photosController.uploadPhoto);
app.post("/delete", photosController.deletePhoto);

exports.photos = functions.https.onRequest(app);


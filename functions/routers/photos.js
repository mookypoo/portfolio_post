const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    //multer = require("multer"),
    //storage = multer.memoryStorage();
    //upload = multer({ storage: storage }).array(),
    photosController = require("../controllers/photos_controller");
    
app.get("/get/:postUid", photosController.getPhoto);
app.post("/upload/:postUid", photosController.uploadPhoto);
app.post("/delete/:postUid", photosController.deletePhoto);

exports.photos = functions.https.onRequest(app);
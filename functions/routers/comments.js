const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    commentsController = require("../controllers/comments_controller");

app.get("/get/:postUid", commentsController.getComment);
app.post("/add/:action", commentsController.addComment);

exports.comments = functions.https.onRequest(app);
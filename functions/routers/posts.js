const express = require("express"),
    app = express(),
    postsController = require("../controllers/posts_controller"),
    functions = require("firebase-functions");

app.post("/add", postsController.addPost);
app.get("/getPreviews", postsController.getPreviews);
app.get("/refreshPreviews", postsController.refreshPreviews);
app.get("/getPost/:postUid", postsController.getPost);
app.post("/like", postsController.like);
app.post("/unlike", postsController.unlike);
app.post("/delete", postsController.deletePost);
app.post("/edit", postsController.edit); // upload - multer 필요? 
app.get("/category", postsController.category);

exports.posts = functions.https.onRequest(app);

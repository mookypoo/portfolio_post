const express = require("express"),
    app = express(),
    serviceAccount = require("../secret/service_account_key.json"),
    admin = require("firebase-admin"),
    { auth } = require("./routers/auth"),
    { posts } = require("./routers/posts"),
    { comments } = require("./routers/comments"),
    { user } = require("./routers/user"),
    { search } = require("./routers/search"),
    { addPreview, deletePreviewAndComment } = require("./controllers/posts_controller"),
    { sendNewFollowerNotification } = require("./controllers/user_controller");

admin.initializeApp({
    projectId: "mooky-post",
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://mooky-post-default-rtdb.asia-southeast1.firebasedatabase.app"
});

// morgan = require("morgan") --> for logging 
// app.use(morgan("dev"));

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use("/auth", auth);
app.use("/posts", posts);
app.use("/comments", comments);
app.use("/search", search);
app.use("/user", user);

module.exports = {
    auth, posts, comments, user, search,
    addPreview, deletePreviewAndComment, sendNewFollowerNotification,
}
    
app.listen(3000, _ => console.log("connected to server"));

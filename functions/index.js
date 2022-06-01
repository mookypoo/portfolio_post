const express = require("express"),
    app = express(),
    serviceAccount = require("./secret/service_account_key.json"),
    admin = require("firebase-admin"),
    { auth } = require("./routers/auth"),
    { posts } = require("./routers/posts"),
    { comments } = require("./routers/comments"),
    { user } = require("./routers/user"),
    { search } = require("./routers/search"),
    { addPreview, deletePreviewAndComment, editPreview } = require("./controllers/posts_controller"),
    { sendNewFollowerNotification } = require("./controllers/user_controller"),
    { photos } = require("./routers/photos");

admin.initializeApp({
    projectId: "mooky-post",
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://mooky-post-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "mooky-post.appspot.com"
});

// morgan = require("morgan") --> for logging 
// app.use(morgan("dev"));

// extended true = any type?? false = string or array 
app.use(express.json()); // { limit: "50mb" }
//app.use(express.urlencoded({ extended: false, limit: "50mb" })); // limit: "50mb"  urlencoded도 필요없는데? 

app.use("/auth", auth);
app.use("/posts", posts);
app.use("/comments", comments);
app.use("/search", search);
app.use("/user", user);
app.use("/photos", photos);

module.exports = {
    auth, posts, comments, user, search, photos,
    addPreview, deletePreviewAndComment, sendNewFollowerNotification, editPreview 
}
    
app.listen(3000, _ => console.log("connected to server"));

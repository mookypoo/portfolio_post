const serviceAccount = require("../secret/service_account_key.json"),
    admin = require("firebase-admin"),
    { auth } = require("./auth"),
    { posts, addPreview, deletePreviewAndComment } = require("./posts"),
    { comments } = require("./comments"),
    { user, sendNewFollowerNotification } = require("./user"),
    { search } = require("./search"),
    express = require("express"),
    app = express();

admin.initializeApp({
    projectId: "mooky-post",
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://mooky-post-default-rtdb.asia-southeast1.firebasedatabase.app"
});

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use("/auth", auth);
app.use("/posts", posts);
app.use("/comments", comments);
app.use("/search", search);
app.use("/user", user);

module.exports = {
    auth, posts, comments, addPreview, deletePreviewAndComment, user, sendNewFollowerNotification,
    search,
}
    
app.listen(3000, _ => console.log("connected to server"));

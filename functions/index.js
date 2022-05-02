const serviceAccount = require("./service_account_key.json"),
    admin = require("firebase-admin"),
    { auth } = require("./auth"),
    { posts, addPreview, deletePreviewAndComment } = require("./posts"),
    { comments } = require("./comments"),
    { user, sendNewFollowerNotification } = require("./user");

admin.initializeApp({
    projectId: "mooky-post",
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://mooky-post-default-rtdb.asia-southeast1.firebasedatabase.app"
});

module.exports = {
    auth, posts, comments, addPreview, deletePreviewAndComment, user, sendNewFollowerNotification
}
    


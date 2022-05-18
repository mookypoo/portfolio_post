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
// addPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref('/posts/{postUid}')
//     .onCreate((snapshot, context) => {
//         const original = snapshot.val();
//         functions.logger.log("adding post preview", context.params.postUid, original);
//         const preview = {
//             postUid: context.params.postUid,
//             title: original.title,
//             text: original.text.substring(0, 100),
//             userName: original.author.userName,
//             createdTime: original.createdTime,
//             category: original.category,
//         };
//         return snapshot.ref.database.ref("/previews").child(context.params.postUid).set(preview);
//     });

// deletePreviewAndComment = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}")
//     .onDelete((snapshot, context) => {
//         functions.logger.log("deleting preview and comment", context.params.postUid);
//         return snapshot.ref.database.ref().set({ [`/previews/${context.params.postUid}`]: null, [`/comments/${context.params.postUid}`]: null,});
//     });

exports.posts = functions.https.onRequest(app);

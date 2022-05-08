const { firebaseConfig } = require("firebase-functions");

const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid");

app.post("/add", async (req, res) => {
    const postUid = uuid.v1();
    req.body.post.postUid = postUid;
    let createdTime = new Date().toISOString();
    req.body.post.createdTime = createdTime;
    try {
        await admin.database().ref("/posts").child(postUid).set(req.body.post);
        res.send({ postUid, createdTime });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

addPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref('/posts/{postUid}')
    .onCreate((snapshot, context) => {
        const original = snapshot.val();
        functions.logger.log("adding post preview", context.params.postUid, original);
        const preview = {
            postUid: context.params.postUid,
            title: original.title,
            text: original.text.substring(0, 100),
            userName: original.author.userName,
            createdTime: original.createdTime,
            category: original.category,
        };
        return snapshot.ref.database.ref("/previews").child(context.params.postUid).set(preview);
    });

deletePreviewAndComment = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}")
    .onDelete((snapshot, context) => {
        functions.logger.log("deleting preview and comment", context.params.postUid);
        return snapshot.ref.database.ref().set({ [`/previews/${context.params.postUid}`]: null, [`/comments/${context.params.postUid}`]: null,});
    });

app.get("/getPreviews", async (req, res) => {
    try {
        let previews = [];
        await admin.database().ref("/previews").orderByChild("createdTime").once("value", async (snapshot) => {
            // 왜 이건 되고 밑에껀 안되지? 
            snapshot.forEach(child => {
                previews.push(child.val());
            });
            //snapshot.forEach(child => previews.push(child.val()));
            
        });
    
        // await new Promise(resolve => {
        //     admin.database().ref("/previews").orderByChild("createdTime").on("value", async (snapshot) => {
        //         // 왜 이건 되고 밑에껀 안되지? 
        //         snapshot.forEach(child => {
        //             previews.push(child.val());
        //         });
        //         //snapshot.forEach(child => previews.push(child.val()));
        //         setTimeout(_ => resolve(), 1000);
        //     });
        // });
        console.log(previews);
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.get("/refreshPreviews", async (req, res) => {
    try {
        
        const _dataSnapshot = await admin.database().ref("/previews").orderByChild("createdTime").equalTo().once("value");
        if (_dataSnapshot.val() != null) previews = Object.values(_dataSnapshot.val());
        res.send({ previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
})

app.get("/getPost/:postUid", async (req, res) => {
    try {
        const _dataSnapshot = await admin.database().ref(`/posts/${req.params.postUid}`).once("value");
        if (_dataSnapshot.val() != null) {
            let post = _dataSnapshot.val();
            if (post.likedUsers) post.likedUsers = Object.keys(_dataSnapshot.val().likedUsers);
            res.send({ post });
        } 
        if (_dataSnapshot.val() == null) res.send({ error: "couldn't find post" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.post("/like", async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}`).update({ numOfLikes: req.body.numOfLikes, [`likedUsers/${req.body.userUid}`]: "liked" });
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.post("/unlike", async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}/likedUsers`).child(req.body.userUid).remove();
        await admin.database().ref(`/posts/${req.body.postUid}`).child("numOfLikes").set(req.body.numOfLikes);
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

verifyPostAuthor = functions.https.onRequest(async (req, res) => {
    const _dataSnapshot = await admin.database().ref(`/usersAuth/${req.body.userUid}/idToken`).once("value");
    if (_dataSnapshot.val() == req.body.idToken) return true;
    if (_dataSnapshot.val() != req.body.idToken) return false;
});

app.post("/delete", async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) await admin.database().ref("/posts").child(req.body.postUid).remove();
        res.send({ deleted: _verified });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.post("/edit", async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) {
            let modifiedTime = new Date().toISOString();
            req.body.updateInfo.modifiedTime = modifiedTime;
            await admin.database().ref("/posts").child(req.body.postUid).update(req.body.updateInfo);
            
            let previewBody = {};
            if (req.body.updateInfo.title) previewBody.title = req.body.updateInfo.title;
            if (req.body.previewText) previewBody.text = req.body.previewText;
            if (previewBody.title || previewBody.text) {
                await admin.database().ref("/previews").child(req.body.postUid).update(previewBody);
            }
            res.send({ modifiedTime });
        }
        if (!_verified) res.send({ error: "user not verified" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.get("/category", async (req, res) => {
    console.log(req.query.category);
    try {
        let previews = [];
        await new Promise(resolve => {
            req.query.category.forEach(async (category) => {
                const _dataSnapshot = await admin.database().ref("/previews").orderByChild("category").equalTo(category).get();
                if (_dataSnapshot.val() != null) {
                    Object.values(_dataSnapshot.val()).forEach(snapshot => previews.push(snapshot));
                }
                console.log(previews);
            });
            setTimeout(_ => {
                resolve();
            }, 1000);
        });
        console.log(previews);
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

module.exports = {
    posts: functions.https.onRequest(app),
    addPreview, deletePreviewAndComment, 
}

category
    - firebase
        - postUid

    - flutter
        - postUid
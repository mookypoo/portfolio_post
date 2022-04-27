const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid"),
    { verifyUser } = require("./auth");

timeToText = (time) => {
    let text = new Date(time).toUTCString();
    text = text.substring(0, text.length - 4);
    return text;
}

app.post("/add", async (req, res) => {
    const postUid = uuid.v1();
    req.body.post.postUid = postUid;
    req.body.post.createdTime = new Date().toISOString();
    const createdTime = timeToText(req.body.post.createdTime);
    try {
        await admin.database().ref("/posts").child(postUid).set(req.body.post);
        res.send({ postUid, createdTime });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

exports.addPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref('/posts/{postUid}')
    .onCreate((snapshot, context) => {
        const original = snapshot.val();
        functions.logger.log("adding post preview", context.params.postUid, original);
        const preview = {
            postUid: context.params.postUid,
            title: original.title,
            text: original.text.substring(0, 100),
            userName: original.author.userName,
            createdTime: original.createdTime,
        };
        return snapshot.ref.database.ref("/previews").child(context.params.postUid).set(preview);
    });

exports.editPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}/modifiedTime")
    .onWrite((change, context) => {
        functions.logger.log("editing preview", context.params.postUid);
        const prevTitle = change.before.ref.parent.child("title").get().val();
        const newTitle = change.after.ref.parent.child("title").get().val();
        const prevText = change.before.ref.parent.child("text").get().val().substring(0, 100);
        const newText = change.after.ref.parent.child("text").get().val().substring(0, 100);
        if (prevTitle == newTitle) {
            if (prevText == newText) return null;
            return change.after.ref.database("/previews").child(context.params.postUid).set({ text: newText });
        }
        if (prevTitle != newTitle) {
            if (prevText == newText) return change.after.ref.database("/previews").child(context.params.postUid).set({ title: newTitle });
            if (prevText != newText) return change.after.ref.database("/previews").child(context.params.postUid).set({ text: newText, title: newTitle });;
        }
        return null;
    });

exports.deletePreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}")
    .onDelete((snapshot, context) => {
        functions.logger.log("deleting preview", context.params.postUid);
        return snapshot.ref.database.ref("/previews").child(context.params.postUid).remove();
    });

app.get("/getPreviews", async (req, res) => {
    try {
        const _dataSnapshot = await admin.database().ref("/previews").orderByChild("createdTime").get();
        let previews = [];
        if (_dataSnapshot.val() != null) {
            previews = Object.values(_dataSnapshot.val());
            res.send({ previews });
        } else {
            console.log("no previews");
        }
        res.send(previews);
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

app.get("/getPost/:postUid", async (req, res) => {
    try {
        const _dataSnapshot = await admin.database().ref(`/posts/${req.params.postUid}`).once("value");
        if (_dataSnapshot.val() != null) {
            let post = _dataSnapshot.val();
            post.createdTime = timeToText(post.createdTime);
            if (post.modifiedTime) post.modifiedTime = timeToText(post.modifiedTime);
            if (post.likedUsers) post.likedUsers = Object.keys(_dataSnapshot.val().likedUsers);
            res.send({ post });
        } else {
            res.send({ error: "couldn't find post" });
        }
        res.send({ post });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

exports.unlike = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/posts/{postUid}/likedUsers/{userUid}")
    .onDelete((snapshot, context) => {
        const numOfLikes = snapshot.ref.parent.parent.child("numOfLikes").once("value");
        functions.logger.log(`numOfLikes: ${numOfLikes - 1}`, context.params.postUid, context.params.userUid);
        return snapshot.ref.database.parent.parent.child("numOfLikes").set(numOfLikes - 1);
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
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

exports.verifyPostAuthor = functions.https.onRequest(async (req, res) => {
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
            modifiedTime = timeToText(modifiedTime);
            res.send({ modifiedTime });
        } else {
            res.send({ error: "user not verified" });
        }
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

module.exports = {
    posts: functions.https.onRequest(app),
    timeToText,
}

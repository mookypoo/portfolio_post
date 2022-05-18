const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid"),
    { getStorage } = require("firebase-admin/storage");

const addPost = async (req, res) => {
    const postUid = uuid.v1();
    req.body.post.postUid = postUid;
    let createdTime = new Date().toISOString();
    req.body.post.createdTime = createdTime;
    try {
        console.log(req.body.post.filePath);
        // todo redo below 
        if (req.body.image != null) await uploadPhoto(req.body.image, req.body.fileName, postUid);
        await admin.database().ref("/posts").child(postUid).set(req.body.post);
        res.send({ postUid, createdTime });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const addPreview = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref('/posts/{postUid}')
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
        return snapshot.ref.database.ref().set({ [`previews/${context.params.postUid}`]: null, [`comments/${context.params.postUid}`]: null, });
    });

const getPreviews = async (req, res) => {
    try {
        let previews = [];
        await admin.database().ref("/previews").orderByChild("createdTime").once("value", async (snapshot) => {
            snapshot.forEach(child => {
                previews.push(child.val());
            });
        });
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const refreshPreviews = async (req, res) => {
    try {
        let previews = [];
        await admin.database().ref("/previews").orderByChild("createdTime").once("value", async (snapshot) => {
            snapshot.forEach(child => {
                previews.push(child.val());
            });
        });
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const getImage = async (fileNames, postUid) => {
    const bucket = getStorage().bucket();
    const filePaths = await new Promise(resolve => {
        let paths = [];
        fileNames.forEach(async fileName => {
            const file = await bucket.file(`${postUid}/${fileName}`).download();
            console.log(file);
            paths.push(file[0]);
        });
        setTimeout(_ => resolve(paths), 3000);
    });
    return filePaths;
}

const getPost = async (req, res) => {
    console.log("getting post");
    try {
        const _dataSnapshot = await admin.database().ref(`/posts/${req.params.postUid}`).once("value");
        if (_dataSnapshot.val() != null) {
            let post = _dataSnapshot.val();
            if (post.likedUsers) post.likedUsers = Object.keys(_dataSnapshot.val().likedUsers);
            if (post.images) {
                const filePaths = await getImage(Object.values(post.images), req.params.postUid);
                post.filePaths = filePaths;
            }
            res.send({ post });
        }
        if (_dataSnapshot.val() == null) res.send({ error: "couldn't find post" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const like = async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}`).update({ numOfLikes: req.body.numOfLikes, [`likedUsers/${req.body.userUid}`]: "liked" });
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const unlike = async (req, res) => {
    try {
        await admin.database().ref(`/posts/${req.body.postUid}/likedUsers`).child(req.body.userUid).remove();
        await admin.database().ref(`/posts/${req.body.postUid}`).child("numOfLikes").set(req.body.numOfLikes);
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const verifyPostAuthor = functions.https.onRequest(async (req, res) => {
    const _dataSnapshot = await admin.database().ref(`/users/${req.body.userUid}/idToken`).get();
    if (_dataSnapshot.val() == req.body.idToken) return true;
    if (_dataSnapshot.val() != req.body.idToken) return false;
});

const deletePost = async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) await admin.database().ref("/posts").child(req.body.postUid).remove();
        res.send({ deleted: _verified });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const uploadPhoto = async (req) => {
    const bucket = getStorage().bucket();
    const images = await new Promise(resolve => {
        let imageFileNames = {};    
        req.body.filePaths.forEach(async path => {
            const imageUid = uuid.v1();
            const subPaths = path.split("/");
            const fileName = subPaths[subPaths.length - 1];
            imageFileNames[imageUid] = fileName;
            await bucket.upload(path, { destination: `${req.body.postUid}/${fileName}`, resumable: true })
        });
        setTimeout(_ => resolve(imageFileNames), 3000)
    });
    req.body.updateInfo.images = images;
}

const edit = async (req, res) => {
    try {
        const _verified = await verifyPostAuthor(req, res);
        if (_verified) {
            let modifiedTime = new Date().toISOString();
            req.body.updateInfo.modifiedTime = modifiedTime;
            if (req.body.filePaths != null) await uploadPhoto(req);

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
}

const category = async (req, res) => {
    console.log(req.query.category);
    try {
        const previews = await new Promise(resolve => {
            let previews = [];
            req.query.category.forEach(async (category) => {
                const _dataSnapshot = await admin.database().ref("/previews").orderByChild("category").equalTo(category).get();
                if (_dataSnapshot.val() != null) {
                    Object.values(_dataSnapshot.val()).forEach(snapshot => previews.push(snapshot));
                }
            });
            setTimeout(_ => resolve(previews), 1000);
        });
        console.log(previews);
        res.send({ previews: previews });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}
 
module.exports = {
    addPost, addPreview, deletePreviewAndComment, getPreviews, refreshPreviews, getPost,
    like, unlike, deletePost, edit, category,
}
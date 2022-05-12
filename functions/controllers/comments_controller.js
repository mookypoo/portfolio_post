const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid");

const getComment = async (req, res) => {
    try {
        const _dataSnapshot = await admin.database().ref(`/comments/${req.params.postUid}`).once("value");
        let comments;
        if (_dataSnapshot.val() != null) {
            comments = Object.values(_dataSnapshot.val());
            comments.forEach(comment => {
                if (comment.comments) comment.comments = Object.values(comment.comments);
                console.log(comment);
            });
        }
        res.send({ comments });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const addComment = async (req, res) => {
    const commentUid = uuid.v1();
    req.body.commentUid = commentUid;
    const createdTime = new Date().toISOString();
    req.body.createdTime = createdTime;
    try {
        if (req.params.action == "comment")
            await admin.database().ref(`/comments/${req.body.postUid}/${commentUid}`).set(req.body);
        if (req.params.action == "commentOnComment")
            await admin.database().ref(`/comments/${req.body.postUid}/${req.body.mainCommentUid}/comments`).child(commentUid).set(req.body);
        res.send({ commentUid, createdTime });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

module.exports = {
    getComment, addComment,
}
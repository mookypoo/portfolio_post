const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    { verifyUser } = require("../controllers/auth_controller");

const checkDeviceToken = async (req, res) => {
    console.log("checking device token");
    try {
        const _dataSnapshot = await admin.database().ref("/usersAuth").child(req.body.userUid).once("value");
        if (_dataSnapshot.val().idToken != req.body.idToken) res.send({ error: "user not verified" });
        if (_dataSnapshot.val().idToken == req.body.idToken) {
            if (_dataSnapshot.val().deviceToken == null) res.send({ data: "need token" });
            if (_dataSnapshot.val().deviceToken) {
                // check if timestamp has been a month  ==> then refresh  with data: "need token"
                res.send({ data: "success" });
            }
        }
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

getDeviceToken = functions.https.onRequest(async (req, _) => {
    console.log("getting user device token");
    const _dataSnapshot = await admin.database().ref(`/usersAuth/${req.body.userUid}`).child("deviceToken").get();
    req.body.deviceToken = _dataSnapshot.val();
});

const saveDeviceToken = async (req, res) => {
    console.log("saving device token");
    try {
        const _verified = await verifyUser(req);
        if (_verified) await admin.database().ref(`/usersAuth/${req.body.userUid}`).child("deviceToken").set(req.body.deviceToken);
        res.end();
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const deleteDeviceToken = async (req, res) => {
    console.log("deleting device token");
    try {
        const _verified = await verifyUser(req);
        if (_verified) await admin.database().ref(`/usersAuth/${req.body.userUid}`).child("deviceToken").remove();
        res.end();
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const setNotification = async (req, res) => {
    try {
        const _verified = await verifyUser(req);
        if (_verified) {
            await admin.database().ref(`/users/${req.body.userUid}`).child("receiveNotifications").set(req.body.receiveNotifications);
            res.send({ data: "success" });
        }
        if (!_verified) res.send({ error: "user not verified" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const saveFollower = functions.https.onRequest(async (req, res) => {
    const followerUid = req.body.userUid;
    const followers = await admin.database().ref(`/followers/${req.body.postAuthorUid}`).child(followerUid).get();
    console.log(followers.val());
    if (followers.val() == null) {
        console.log("adding follower");
        const followerInfo = {
            deviceToken: req.body.deviceToken,
            name: req.body.userName,
        }
        await admin.database().ref(`/followers/${req.body.postAuthorUid}`).child(followerUid).set(followerInfo);
        return "successfully followed";
    }
    if (followers.val() != null) {
        console.log("removing follower");
        await admin.database().ref(`/followers/${req.body.postAuthorUid}`).child(followerUid).remove();
        return "successfully unfollowed";
    }
});

saveFollowing = functions.https.onRequest(async (req, res) => {
    console.log("saving following");
    const followingUid = req.body.postAuthorUid;
    const following = await admin.database().ref(`/users/${req.body.userUid}/following`).child(followingUid).get();
    if (following.val() == null) {
        console.log("adding new author to follow");
        await admin.database().ref(`/users/${req.body.userUid}/following`).child(followingUid).set("follow");
        return "successfully followed";
    }
    if (following.val()) {
        console.log("unfollowing");
        await admin.database().ref(`/users/${req.body.userUid}/following`).child(followingUid).remove();
        return "successfully unfollowed";
    }
});

const follow = async (req, res) => {
    try {
        // todo 여기 뭔가 하나가 잘못되면 나머지도 다시 원상복귀해야되는데...
        await getDeviceToken(req, res);
        const savingFollower = await saveFollower(req, res);
        const savingFollowing = await saveFollowing(req, res);
        if (savingFollower == savingFollowing) res.send({ data: savingFollowing });
        if (savingFollower != savingFollowing) res.send({ error: "Temporary Error: please try again later" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const sendNewFollowerNotification = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/followers/{followedUid}/{followerUid}")
    .onWrite(async (change, context) => {
        const followerUid = context.params.followerUid;
        const followedUid = context.params.followedUid;

        if (!change.after.val()) return functions.logger.log(followedUid, "unfollowed by", followerUid);

        functions.logger.log("added follower info", change.after.val()); // should be { deviceToken: ... , name: ... }
        const receiveNotifications = await admin.database().ref(`/users/${followedUid}`).child("receiveNotifications").get();
        if (!receiveNotifications) return functions.logger.log(followedUid, "does not receive notifications");
        if (receiveNotifications) {
            const deviceToken = await admin.database().ref(`/usersAuth/${followedUid}`).child("deviceToken").get();
            functions.logger.log("sending notification to followed user ");
            const followerName = change.after.val().name;
            const payload = {
                notification: {
                    title: "You have a new follower!",
                    body: `${followerName} is now following you.`,
                }
            };
            const response = await admin.messaging().sendToDevice(deviceToken.val(), payload);
            return functions.logger.log("payload", payload, response);
        }
        return functions.logger.log("attempted to send new follower notification");
    });

const getUserInfo = async (req, res) => {
    try {
        const userSnapshot = await admin.database().ref(`/users`).child(req.params.userUid).get();
        let userInfo = userSnapshot.val();
        if (userInfo == null) res.send({ error: "couldnt find user" });
        if (userInfo != null) {
            if (userInfo.following != null) userInfo.following = Object.keys(userInfo.following);
            console.log(`userInfo: ${userInfo}`);
            res.send({ userInfo });
        }
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

module.exports = {
    checkDeviceToken, saveDeviceToken, deleteDeviceToken, setNotification,
    follow, sendNewFollowerNotification, getUserInfo,
}
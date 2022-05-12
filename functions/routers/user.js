const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    userController = require("../controllers/user_controller");
 
app.post("/checkDeviceToken", userController.checkDeviceToken);
app.post("/saveDeviceToken", userController.saveDeviceToken);
app.post("/deleteDeviceToken", userController.deleteDeviceToken);
app.post("/setNotifications", userController.setNotification);
app.post("/follow", userController.follow);
app.get("/getInfo/:userUid", userController.getUserInfo);

// sendNewFollowerNotification = functions.region("asia-northeast3").database.instance("mooky-post-default-rtdb").ref("/followers/{followedUid}/{followerUid}")
//     .onWrite(async (change, context) => {
//         const followerUid = context.params.followerUid;
//         const followedUid = context.params.followedUid;
        
//         if (!change.after.val()) return functions.logger.log(followedUid, "unfollowed by", followerUid);
        
//         functions.logger.log("added follower info", change.after.val()); // should be { deviceToken: ... , name: ... }
//         const receiveNotifications = await admin.database().ref(`/users/${followedUid}`).child("receiveNotifications").get();
//         if (!receiveNotifications) return functions.logger.log(followedUid, "does not receive notifications");
//         if (receiveNotifications) {
//             const deviceToken = await admin.database().ref(`/usersAuth/${followedUid}`).child("deviceToken").get();
//             functions.logger.log("sending notification to followed user ");
//             const followerName = change.after.val().name;
//             const payload = {
//                 notification: {
//                     title: "You have a new follower!",
//                     body: `${followerName} is now following you.`,
//                 }
//             };
//             const response = await admin.messaging().sendToDevice(deviceToken.val(), payload);
//             return functions.logger.log("payload", payload, response);
//         }
//         return functions.logger.log("attempted to send new follower notification");
//     });

exports.user = functions.https.onRequest(app);

const express = require("express"),
    app = express(),
    axios = require("axios"),
    
    endPoint = (firebasePath) => `https://identitytoolkit.googleapis.com/v1/accounts:${firebasePath}?key=${firebaseAPI}`,
    functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    qs = require("qs");

app.post("/sign/:action", async (req, res) => {
    let path = "signUp";
    if (req.params.action == "in") path = "signInWithPassword";
    try {
        const res = await axios.post(
            endPoint(path),
            req.body,
            { headers: { "content-type": "application / json" } },
        );
        console.log(res.data.localId);
        if (req.params.action == "in") await admin.database().ref(`/usersAuth/${res.data.localId}`).child("idToken").update(res.data.idToken);
        res.send({ data: res.data });
    } catch (e) {
        console.log(e.response.data);
        res.send(e.response.data);
    }
});

app.post("/saveUserInfo", async (req, res) => {
    console.log(req.body.info);
    try {
        await admin.database().ref("/users").child(req.body.userUid).set(req.body.info);
        await admin.database().ref("/usersAuth").child(req.body.userUid).set({ idToken: req.body.idToken });
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

verifyUser = async (req) => {
    const _dataSnapshot = await admin.database().ref("/usersAuth").child(req.body.userUid).once("value");
    if (_dataSnapshot.val() == null) return false;
    if (_dataSnapshot.val().idToken != req.body.idToken) return false;
    if (_dataSnapshot.val().idToken == req.body.idToken) return true;
}

app.post("/autoAuth", async (req, res) => {
    try {
        const _verified = await verifyUser(req);
        if (!_verified) res.send({ error: "user not verified" });
        if (_verified) res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

//"content-type": "application/x-www-form-urlencoded"  이면 data json format을 qs.stringify()
app.post("/refreshToken", async (req, res) => {
    const _path = `https://securetoken.googleapis.com/v1/token?key=${firebaseAPI}`;
    const _body = {
        "grant_type": "refresh_token",
        "refresh_token": `${req.body.refreshToken}`
    };
    const _header = { headers: { "content-type": "application/x-www-form-urlencoded" } };
    try {
        const _res = await axios.post(_path, qs.stringify(_body), _header);
        await admin.database().ref("/usersAuth").child(req.body.userUid).update({ "idToken": _res.data.id_token });
        res.send({ data: _res.data });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

module.exports = {
    auth: functions.https.onRequest(app),
    verifyUser
}
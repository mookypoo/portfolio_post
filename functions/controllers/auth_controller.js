const express = require("express"),
    axios = require("axios"),
    qs = require("qs"),
    admin = require("firebase-admin"),
    { firebaseAPI } = require("../secret/firebaseAPI"),
    endPoint = (firebasePath) => `https://identitytoolkit.googleapis.com/v1/accounts:${firebasePath}?key=${firebaseAPI}`;

const verifyUser = async (req) => {
    const _dataSnapshot = await admin.database().ref(`/users/${req.body.userUid}`).child("idToken").get();
    if (_dataSnapshot.val() == null || _dataSnapshot.val() != req.body.idToken) return false;
    if (_dataSnapshot.val() == req.body.idToken) return true;
}

const sign = async (req, res) => {
    let path = "signUp";
    console.log("signing in");
    if (req.params.action == "in") path = "signInWithPassword";
    try {
        const _res = await axios.post(
            endPoint(path),
            req.body,
            { headers: { "content-type": "application / json" } },
        );
        if (req.params.action == "in") await admin.database().ref(`/users`).child(_res.data.localId).update({ "idToken": `${_res.data.idToken}` });
        res.send({ data: _res.data });
    } catch (e) {
        console.log(e);
        console.log(e.response.data);
        res.send(e);
    }
}

const saveUserInfo = async (req, res) => {
    try {
        await admin.database().ref("/users").child(req.body.userUid).set(req.body.info);
        res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const autoAuth = async (req, res) => {
    try {
        const _verified = await verifyUser(req);
        if (!_verified) res.send({ error: "user not verified" });
        if (_verified) res.send({ data: "success" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const refreshToken = async (req, res) => {
    const _path = `https://securetoken.googleapis.com/v1/token?key=${firebaseAPI}`;
    const _body = {
        "grant_type": "refresh_token",
        "refresh_token": `${req.body.refreshToken}`
    };
    const _header = { headers: { "content-type": "application/x-www-form-urlencoded" } };
    try {
        const _res = await axios.post(_path, qs.stringify(_body), _header);
        await admin.database().ref("/users").child(req.body.userUid).update({ "idToken": _res.data.id_token });
        res.send({ data: _res.data });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

module.exports = {
    sign, autoAuth, refreshToken, saveUserInfo, verifyUser
}
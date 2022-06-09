const { verifyPostAuthor } = require("./posts_controller"),
    { getStorage } = require("firebase-admin/storage");

const uploadPhoto = async (req, res) => {
    console.log("uploading photo");
    try {
        const verified = await verifyPostAuthor(req, res);
        if (verified) {
            const bucket = getStorage().bucket();
            await new Promise(resolve => {
                req.body.photos.forEach(async photo => {
                    var buffer = new Uint8Array(photo.bytes);
                    var file = bucket.file(photo.fileName);
                    await file.save(buffer, { resumable: true });
                });
                setTimeout(_ => resolve(), 3000)
            });
            res.send({ data: "success" });
        }
        if (!verified) res.send({ error: "user not verified" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

const getPhoto = async (req, res) => {
    console.log("getting photo");
    const bucket = getStorage().bucket();
    try {
        const response = await bucket.getFiles({ prefix: req.params.postUid });
        if (response[0].length == 0) res.send({ photos: [] });
        if (response[0].length != 0) {
            const files = Object.values(response[0]);
            const photos = await new Promise(resolve => {
                let data = [];
                files.forEach(async file => {
                    const fileName = file.name;
                    const photo = await file.download();
                    data.push({ fileName, bytes: photo[0] });
                });
                setTimeout(_ => resolve(data), 3000);
            });
            res.send({ photos });
        }
    } catch (e) {
        console.log(e);
        res.send({ error: e });l
    }
}

const deletePhoto = async (req, res) => {
    console.log("deleting image");
    try {
        const verified = await verifyPostAuthor(req, res);
        if (verified) {
            const bucket = getStorage().bucket();
            await bucket.file(`${req.body.fileName}`).delete();
            res.send({ data: "success" });
        }
        if (!verified) res.send({ error: "user not verified" });
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
}

module.exports = {
    uploadPhoto, getPhoto, deletePhoto, 
}
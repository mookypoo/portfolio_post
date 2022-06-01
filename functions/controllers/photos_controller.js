const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    { verifyPostAuthor } = require("./posts_controller"),
    //multer = require("multer"),
    //storage = multer.memoryStorage(),
    //upload = multer({ dest: "uploads/" }),
    fs = require("fs"),
    
    { getStorage } = require("firebase-admin/storage");

const uploadPhoto = async (req, res) => {
    console.log("uploading photo");
    try {
        const verified = await verifyPostAuthor(req, res);
        if (verified) {
            const bucket = getStorage().bucket();
            console.log(1);
            const response = await new Promise(resolve => {
                req.body.filePaths.forEach(async filePath => {
                    console.log(2);
                    var huh = new File(filePath);
                    fs.writeFileSync(`${filePath}`, filePath);
                    //var huh = fs.readFileSync(`${filePath}`, { encoding:  });
                    console.log(huh);
                    const subPaths = filePath.split("/");
                    const fileName = subPaths[subPaths.length - 1];
                    console.log(3);
                    await bucket.upload(filePath, { destination: `${req.params.postUid}/${fileName}`, resumable: true })
                });
                setTimeout(_ => resolve(), 3000)
            });
            console.log(response);
            res.send({ data: "success" });
        }
        console.log(4);
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
        const verified = await verifyPostAuthor;
        if (verified) {
            const bucket = getStorage().bucket();
            await bucket.file(`${req.body.fileName}`).delete();
            // await admin.database().ref(`/posts/${req.params.postUid}/images`).child(req.body.imageUid).remove();
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
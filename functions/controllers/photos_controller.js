const functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    uuid = require("uuid"),
    { getStorage } = require("firebase-admin/storage");

const uploadPhoto = async (req, isEdit) => {
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
    if (isEdit) await admin.database().ref("images").child(req.body.postUid).update(images);
    if (!isEdit) await admin.database().ref("images").child(req.body.postUid).set(images);
}

module.exports = {
    uploadPhoto, 
}
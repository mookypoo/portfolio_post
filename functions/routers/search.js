const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    admin = require("firebase-admin"),
    { previewText } = require("../controllers/posts_controller");

const searchPreview = (text, searchRegExp) => {
    const index = searchRegExp.exec(text).index;
    const lastPeriod = text.substring(0, index).lastIndexOf(".") + 1;
    
    let nextPeriod = text.indexOf(".", index + searchRegExp.toString().length) + 1;
    if (nextPeriod == 0) nextPeriod = text.length;
    let searchSentence = text.substring(lastPeriod, nextPeriod).trim();
    
    if (searchSentence.length < 250) {
        nextPeriod = text.indexOf(".", lastPeriod + searchSentence.length) + 1;
        if (nextPeriod == 0) nextPeriod = text.length;
        searchSentence = text.substring(lastPeriod, nextPeriod).trim();
    }
    if (nextPeriod < text.length) searchSentence += " ...";
    
    return searchSentence;
}
    
app.get("/:searchText", async (req, res) => {
    console.log(req.params.searchText);
    try {
        const _dataSnapshot = await admin.database().ref("/posts").get();
        const posts = Object.values(_dataSnapshot.val());
        const searchRegExp = new RegExp(req.params.searchText, "gi"); // "gi" = case insensitive search
        let searchedPosts = [];
        posts.forEach(post => {
            if (post.title.match(searchRegExp) || post.text.match(searchRegExp)) searchedPosts.push(post);
        });
        if (searchedPosts.length == 0) res.send({ data: searchedPosts });
        if (searchedPosts.length > 0) {
            let previews = [];
            searchedPosts.forEach(post => {
                let preview = { createdTime: post.createdTime, postUid: post.postUid, title: post.title, userName: post.author.userName };
                if (post.text.match(searchRegExp)) preview.text = searchPreview(post.text, searchRegExp);
                if (!post.text.match(searchRegExp)) preview.text = previewText(post.text);
                previews.push(preview);
            });
            res.send({ data: previews });
        }
    } catch (e) {
        console.log(e);
        res.send({ error: e });
    }
});

exports.search = functions.https.onRequest(app);

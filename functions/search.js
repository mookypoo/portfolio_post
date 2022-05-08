const express = require("express"),
    app = express(),
    functions = require("firebase-functions"),
    admin = require("firebase-admin");

app.get("/:searchText", async (req, res) => {
    console.log(req.params.searchText);
    try {
        const _dataSnapshot = await admin.database().ref("/posts").get();
        const posts = Object.values(_dataSnapshot.val());
        const searchText = new RegExp(req.params.searchText, "gi");
        let searchedPosts = [];
        posts.forEach(post => {
            if (post.title.match(searchText) || post.text.match(searchText)) searchedPosts.push(post);
        });
        if (searchedPosts.length == 0) {
            res.send({ data: searchedPosts })
        } else {
            let previews = [];
            searchedPosts.forEach(post => {
                let preview = { createdTime: post.createdTime, postUid: post.postUid, title: post.title, userName: post.author.userName };
                if (post.text.match(searchText)) {
                    let matchIndice = [];
                    while ((match = searchText.exec(post.text)) != null) matchIndice.push(match.index);
                    
                    const searchTextLength = req.params.searchText.length;
                    let subText = "";
                    let frontEllipsis = 0;
                    let backEllipsis;
                    for (i = 0; i < matchIndice.length; i++){
                        backEllipsis = matchIndice[i + 1] + searchTextLength;
                        if (isNaN(backEllipsis)) backEllipsis = post.text.length;
                        
                        let start = matchIndice[i] - 50;
                        let end = matchIndice[i] + searchTextLength + 50;

                        let newText = post.text.substring(start, end);
                        if (start > frontEllipsis) newText = "..." + newText;
                        if (end < backEllipsis) newText = newText + "...";
                        frontEllipsis = backEllipsis;
                        subText += newText;
                        if (subText.length > 160) subText = subText.substring(0, 160) + "...";
                    }
                    preview.text = subText;
                } else {
                    preview.text = post.text.substring(0, 165) + "...";
                }             
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

global class StoreConnectCommentInfo {

    global StoreConnectCommentInfo(ConnectApi.Comment inComment) {
        comment = inComment;
        userName = inComment.user.name;
            
        imageUrl = '';
        if (inComment.attachment != null && inComment.attachment instanceof ConnectApi.ContentAttachment) {
            ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)inComment.attachment;
            imageUrl = content.renditionUrl;
        }
            
        formattedText = StoreConnectFeedFormatter.formatBodyText(inComment.body);
    }
    
    global ConnectApi.Comment comment { get; private set; }
    global String userName { get; private set; }
    global String imageUrl { get; private set; }
    global String formattedText { get; private set; }
}
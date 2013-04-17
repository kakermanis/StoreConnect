// Copyright 2013, Kevin Akermanis - Sales Engineering, Salesforce.com Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the salesforce.com nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

global class StoreConnectChatterController {
    
    // get first page of news feed
    global static ConnectApi.FeedItemPage getNewsFeed() {
        return ConnectApi.ChatterFeeds.getFeedItemsFromFeed(null, ConnectApi.FeedType.News, 'me');
    }    
        
    global static List<StoreConnectFeedItemInfo> getNewsFeedForDisplay() {      
        ConnectApi.FeedItemPage feed = getNewsFeed();                              
        List<StoreConnectFeedItemInfo> result = new List<StoreConnectFeedItemInfo>();
        for (ConnectApi.FeedItem item : feed.items) {        
            if (item.type != ConnectApi.FeedItemType.EmailMessageEvent ) {
                result.add(new StoreConnectFeedItemInfo(item));            
            }        
        }        
        return result;      
    }  
    
        
    @RemoteAction
    global static String doStatusPost(String statusText) {
        String result = 'success';        
        postTextFeedItem(statusText);                
        return result;
    }
    
    @RemoteAction
    global static String doCommentPost(String parentPostId, String commentText) {
        String result = 'success';
    
        //TODO - implment posting a comment
    
        return result;
    }
    
    @RemoteAction
    global static String doLikePost(String postId) {
        String result = 'success';    
        //TODO - implement liking a post    
        return result;    
    }
    
    
    global static void postTextFeedItem(String feedItemText) {
        ConnectApi.FeedItemInput feedItemInput = StoreConnectFeedBodyParser.convertToFeedItemInput(feedItemText);
        ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.News, 'me', feedItemInput, null);
    }
    
            
    @RemoteAction
    global static List <NewsFeed> loadNewsFeed() {      
        List <NewsFeed> aNewsFeed = [
           SELECT Id, Type, CreatedBy.Name, Parent.Name, Body
              FROM NewsFeed
              ORDER BY CreatedDate DESC, Id DESC LIMIT 20
        ];       
        return aNewsFeed;      
    }                                         
}
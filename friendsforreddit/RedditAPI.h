//
//  RedditAPI.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models/Comment.h"
#import "Models/Post.h"
#import "Models/User.h"


typedef void (^NSDataHandler)(NSData *, NSError *);
typedef void (^NSArrayHandler)(NSArray *, NSError *);
typedef void (^NSErrorHandler)(NSError *);


@interface RedditAPI : NSObject

@property NSString *accessToken;
@property NSString *refreshToken;

+ (RedditAPI *) sharedRedditAPI;

- (void) requestAccessToken;
- (void) refreshAccessToken;

- (void) getPostsAfterPostID: (NSString *)postId InOrder: (NSString *)order Completion:(NSArrayHandler) completion;
- (void) getCommentsAfterCommentID: (NSString *)commentId InOrder: (NSString *)order Completion:(NSArrayHandler) completion;
-(void) getCommentTree:(id)post Completion:(NSErrorHandler) completion;

- (void) getFriendsWithCompletion:(NSArrayHandler) completion;

- (void) addFriendWithName: (NSString *)userName OnError:(NSErrorHandler)errorHandler;
- (void) removeFriendWithName: (NSString *)userName;
- (void) replyToPostWithID: (NSString *)postID Type:(NSString *)parentType WithText: (NSString *)commentText OnError:(NSErrorHandler)errorHandler;
- (void) castVoteForPostWithID: (NSString *)postID Type:(NSString *)postType InDirection: (int) voteDirection;
- (void) deleteUserPostWithID: (NSString *)postID;


@end

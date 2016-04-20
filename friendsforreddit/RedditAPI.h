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


@interface RedditAPI : NSObject

@property NSString *accessToken;
@property NSString *refreshToken;

+ (RedditAPI *) sharedRedditAPI;

- (void) requestAccessToken;
- (void) refreshAccessToken;

- (void) getPostsAfterPostID: (NSString *)postId InOrder: (NSString *)order Completion:(NSArrayHandler) completion;
- (void) getCommentsAfterCommentID: (NSString *)commentId InOrder: (NSString *)order Completion:(NSArrayHandler) completion;
- (void) getFriendsWithCompletion:(NSArrayHandler) completion;

- (void) addFriendWithName: (NSString *)userName;
- (void) removeFriendWithName: (NSString *)userName;
- (void) replyToPostWithID: (NSString *)postID WithText: (NSString *)commentText;
- (void) castVoteForPostWithID: (NSString *)postID InDirection: (int) voteDirection;
- (void) deleteUserPostWithID: (NSString *)postID;


@end

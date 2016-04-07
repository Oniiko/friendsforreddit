//
//  RedditAPI.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditAPI : NSObject

@property NSString *accessToken;
@property NSString *refreshToken;

- (void) requestAccessToken;
- (void) refreshAccessToken;

- (NSArray *) getPostsAfterPostID: (NSString *)postId InOrder: (NSString *)order;
- (NSArray *) getCommentsAfterCommentID: (NSString *)commentId InOrder: (NSString *)order;
- (NSArray *) getFriends;

- (void) addFriendWithName: (NSString *)userName;
- (void) removeFriendWithName: (NSString *)userName;
- (void) replyToPostWithID: (NSString *)postID WithText: (NSString *)commentText;
- (void) castVoteForPostWithID: (NSString *)postID InDirection: (int) voteDirection;
- (void) deleteUserPostWithID: (NSString *)postID;


@end

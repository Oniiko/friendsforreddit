//
//  Post.h
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

    @property (nonatomic, copy, readonly) NSString *title;
    @property (nonatomic, copy, readonly) NSString *author;
    @property (nonatomic, copy, readonly) NSDate *created;
    @property (nonatomic, copy, readonly) NSString *selftext;
    @property (nonatomic, copy, readonly) NSString *subreddit;
    @property (nonatomic, copy, readonly) NSURL *url;
    @property (nonatomic, assign, readonly) NSUInteger num_comments;
    @property (nonatomic, assign, readonly) NSUInteger score;
    @property (nonatomic, assign, readonly) CGFloat upvoteRatio;

    //If voted on by logged-in user
    @property (nonatomic, copy, readonly) BOOL likes;

@end

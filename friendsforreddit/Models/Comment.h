//
//  Comment.h
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

    @property (nonatomic, copy, readonly) NSString *author;
    @property (nonatomic, copy, readonly) NSString *body;
    @property (nonatomic, copy, readonly) NSString *parent_id;
    @property (nonatomic, copy, readonly) NSString *link_title;
    @property (nonatomic, copy, readonly) NSString *link_id;
    @property (nonatomic, copy, readonly) NSString *comment_id;
    @property (nonatomic, copy, readonly) NSString *subreddit;
    @property (nonatomic, copy, readonly) NSString *link_url;
    @property (nonatomic, copy, readonly) NSDate *created;
    @property (nonatomic, assign, readonly) NSUInteger score;
    @property (nonatomic, assign, readonly) BOOL score_hidden;
    @property (nonatomic, assign, readonly) NSMutableArray *replies;
    @property (nonatomic, copy, readonly) NSURL *perm_link_url;

    //If voted on by logged-in user
    @property (nonatomic, assign) NSInteger vote;

-(id) initWithDictionary:(NSDictionary *) dictionary;

-(void) populateRepliesWithArray:(NSArray *) array;

-(NSString *) getRawLinkID;

@end

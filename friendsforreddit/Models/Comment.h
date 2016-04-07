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
    @property (nonatomic, copy, readonly) NSString *link_url;
    @property (nonatomic, copy, readonly) NSUInteger score;
    @property (nonatomic, copy, readonly) BOOL score_hidden;
    @property (nonatomic, copy, readonly) NSMutableArray *replies;

    //If voted on by logged-in user
    @property (nonatomic, copy, readonly) BOOL likes;

@end

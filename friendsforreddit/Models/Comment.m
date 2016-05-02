//
//  Comment.m
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import "Comment.h"




@implementation Comment


@synthesize author;
@synthesize body;
@synthesize parent_id;
@synthesize link_title;
@synthesize score;
@synthesize created;
@synthesize comment_id;
@synthesize subreddit;
@synthesize vote;

-(id) initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if (!self)
        return nil;
    
    
    author = dictionary[@"author"];
    body = dictionary[@"body"];
    link_title = dictionary[@"link_title"];
    parent_id = dictionary[@"parent_id"];
    score = [dictionary[@"score"] integerValue];
    comment_id = dictionary[@"id"];
    subreddit = dictionary[@"subreddit"];
    
    //Parse out the user's comment on this post (ugly)
    if ([dictionary objectForKey:@"likes"]){
        if ([dictionary[@"likes"] isKindOfClass:[NSNull class] ]){
            vote = 0;
        }
         else if ([dictionary[@"likes"] boolValue] == YES){
            vote = 1;
        } else {
            vote = -1;
        }
    }
    
    NSTimeInterval epochTime = [dictionary[@"created"] doubleValue];
    created = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    
    
    
    return self;
    
}

@end

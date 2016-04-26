//
//  Post.m
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import "Post.h"

@implementation Post

@synthesize author;
@synthesize link_title;
@synthesize selftext;
@synthesize created;
@synthesize subreddit;
@synthesize score;
@synthesize num_comments;
@synthesize url;
@synthesize thumbnail_url;
@synthesize post_id;
@synthesize isSelfPost;


-(id) initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if (!self)
        return nil;
    
    
    author = dictionary[@"author"];
    link_title = dictionary[@"title"];
    selftext = dictionary[@"selftext"];
    subreddit = dictionary[@"subreddit"];
    post_id = dictionary[@"id"];
    score = [dictionary[@"score"] integerValue];
    num_comments = [dictionary[@"num_comments"] integerValue];

    
    NSTimeInterval epochTime = [dictionary[@"created"] doubleValue];
    created = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    
    url = [[NSURL alloc] initWithString:dictionary[@"url"]];
    isSelfPost = [dictionary[@"url"] containsString: @"reddit.com"];
    
    thumbnail_url = [[NSURL alloc] initWithString:dictionary[@"thumbnail"]];

    
    return self;
    
}

@end

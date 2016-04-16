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
@synthesize title;
@synthesize selftext;
@synthesize created;
@synthesize subreddit;
@synthesize score;
@synthesize num_comments;
@synthesize url;


-(id) initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if (!self)
        return nil;
    
    
    author = dictionary[@"author"];
    title = dictionary[@"title"];
    selftext = dictionary[@"selftext"];
    subreddit = dictionary[@"subreddit"];
    score = [dictionary[@"score"] integerValue];
    num_comments = [dictionary[@"num_comments"] integerValue];
    
    NSTimeInterval epochTime = [dictionary[@"created"] doubleValue];
    created = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    
    url = [[NSURL alloc] initWithString:dictionary[@"url"]];

    
    return self;
    
}

@end

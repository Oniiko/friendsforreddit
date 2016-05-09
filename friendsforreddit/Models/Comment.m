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
@synthesize perm_link_url;
@synthesize link_id;
@synthesize replies;

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
    link_id = dictionary[@"link_id"];
    NSString *perm_link_string = [[NSString alloc] initWithFormat:@"%@%@", dictionary[@"link_url"], comment_id];
    perm_link_url = [[NSURL alloc] initWithString:perm_link_string];

    
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

-(void) populateRepliesWithArray:(NSArray *) array{
    
    for (NSDictionary *reply in array){
        Comment *comment = [[Comment alloc] initWithDictionary:reply[@"data"]];
        if (![[reply objectForKey:@"replies"] isKindOfClass:[NSString class]]){
            [comment populateRepliesWithArray:reply[@"replies"][@"data"][@"children"]];
        }
        [self.replies addObject:comment];
    }
    
    
}

-(NSString *) getRawLinkID{
    
    return [link_id stringByReplacingOccurrencesOfString:@"t3_"
                                         withString:@""];
}



@end

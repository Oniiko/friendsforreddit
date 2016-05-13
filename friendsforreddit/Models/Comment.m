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
@synthesize depth;

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
    depth = 0;
        self.replies = [[NSMutableArray alloc] init];
    
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

/*
 * Recursively populates the replies array with the comment tree
 *
 * Array: a JSON array corresponding to the replies data for this post
 */
-(void) populateRepliesWithArray:(NSArray *) array{
    
    for (NSDictionary *reply in array){
        Comment *comment = [[Comment alloc] initWithDictionary:reply[@"data"]];
        comment.depth = self.depth + 1;
        if (![[reply[@"data"] objectForKey:@"replies"] isKindOfClass:[NSString class]] &&
            ![reply[@"data"][@"replies"][@"data"][@"children"][0][@"kind"] isEqualToString:@"listing"]){
            NSArray *currentReplies = [[NSArray alloc] init];
            currentReplies = reply[@"data"][@"replies"][@"data"][@"children"];
            [comment populateRepliesWithArray:currentReplies];
        }
        [self.replies addObject: comment];
    }
    
    
}

/*
 * Flattens all child comments into a single 1 dimensional array in "display order"
 */
-(NSArray *) getFlattenedCommentTree{
    
    //First add current comment to the array
    NSMutableArray *tree = [[NSMutableArray alloc] init];

    
    //Return if no children
    if ([self.replies count] < 1){
        return nil;
    }

    //Recursively grab child comments
    for (Comment *comment in replies){
        NSArray *children = [comment getFlattenedCommentTree];
        [tree addObject:comment];

        if (children){
            [tree addObjectsFromArray:children];
        }
    }
    
    return [tree copy];
}

-(NSString *) getRawLinkID{
    
    return [link_id stringByReplacingOccurrencesOfString:@"t3_"
                                         withString:@""];
}



@end

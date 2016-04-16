//
//  RedditAPI.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "RedditAPI.h"
#import "Constants.h"

@implementation RedditAPI

@synthesize accessToken;
@synthesize refreshToken;

/**
- (NSData *) makeAPIRequestWithURL:(NSURL *) url {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url] ;
    
    NSString *bearerToken = [[NSString alloc] initWithFormat:@"bearer %@", accessToken];
    [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [request setValue:UserAgent forHTTPHeaderField:@"User-Agent"];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
                                        
                                        // Code to run when the response completes...
                                    }];
    
}
**/


@end

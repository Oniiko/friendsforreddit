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


#import "RedditAPI.h"
#import "Constants.h"

static RedditAPI *sharedRedditAPI = nil;    // static instance variable


/*
 * Class method for getting singleton
 */
+ (RedditAPI *)sharedRedditAPI {
    if (sharedRedditAPI == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sharedRedditAPI = [[self alloc] init];
        });
    }
    return sharedRedditAPI;
}

/*
 * Method used to make all API requests once access token has been obtained.
 *
 * TODO: implement error handling
 */
- (void) makeAPIRequestWithURL:(NSURL *) url
                        Method:(NSString *) method
                      SendData:(NSData *) sendData
                WithCompletion:(NSDataHandler) completion {
    
    ///////////////FOR TESTING PURPOSES ///////////////
    ///////////////Must be updated hourly//////////////
    accessToken = @"35286854-vDyXs_fegh5a1iCexL1A2I2jW6M";
    ///////////////////////////////////////////////////
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url] ;
    
    NSString *bearerToken = [[NSString alloc] initWithFormat:@"bearer %@", accessToken];
    [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [request setValue:UserAgent forHTTPHeaderField:@"User-Agent"];
    
    [request setHTTPMethod: method];
    
    if (sendData){
        [request setHTTPBody: sendData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSLog(@"Making api request to reddit");
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                                        
                                        if (error){
                                            NSLog(@"Error in makeAPIRequest");
                                            //Cannot connect to reddit
                                        } else {
                                            NSLog(@"Request Succesful");
                                            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *) response;
                                            NSLog(@"http response code %ld", urlResponse.statusCode);
                                            long statusCode = urlResponse.statusCode;
                                            
                                            if (statusCode == 401){
                                                //Bad Authorization, refresh token
                                            } else {
                                                NSError *error = [NSError errorWithDomain:@"HTTP Error"
                                                                                     code:statusCode
                                                                                 userInfo:@{@"response":response}];
                                            }
                                            
                                        }
                                        
                                        completion(data, error);
                                    }];
    [task resume];
    
}

-(void) makeAPIRequestWithURL:(NSURL *) url
                       Method:(NSString *) method
               WithCompletion:(NSDataHandler) completion{
    
    [self makeAPIRequestWithURL:url Method:method SendData:nil WithCompletion:completion];
    
}


/*
 * API Endpoint: /r/friends
 # Method: GET
 *
 * postId: ID of post to start fetching after, leave nil for start of listing
 * order: "Hot" or "New"
 * completion: Code block to deal with NSArray of Post objects created by request
 */
- (void) getPostsAfterPostID: (NSString *)postId InOrder: (NSString *)order Completion:(NSArrayHandler) completion{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/r/friends",BaseURL];
    
    
    if (postId){
        [urlString appendFormat:@"/?count=25&after=%@",postId];
    }
    
    [urlString appendString:@".json"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [self makeAPIRequestWithURL:url Method:@"GET" WithCompletion:^(NSData *data, NSError *error) {
        NSError *serializationError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&serializationError];
        
        NSMutableArray *postArray =  [[NSMutableArray alloc] init];
        
        for (NSDictionary *child in json[@"data"][@"children"]){
            Post *post = [[Post alloc] initWithDictionary:child[@"data"]];
            [postArray addObject:post];
        }
        
        completion(postArray, error);
        
    }];
    
}

/*
 * API Endpoint: /r/friends/comments
 # Method: GET
 *
 * commentId: ID of comment to start fetching after, leave nil for start of listing
 * order: "Hot" or "New"
 * completion: Code block to deal with NSArray of Comment objects created by request
 */
- (void) getCommentsAfterCommentID:(NSString *)commentId
                           InOrder:(NSString *)order
                        Completion:(NSArrayHandler)completion{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/r/friends/comments",BaseURL];
    
    if (commentId){
        [urlString appendFormat:@"/?count=25&after=t1_%@",commentId];
    }
    
    NSLog(urlString);
    
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    [self makeAPIRequestWithURL:url Method:@"GET" WithCompletion:^(NSData *data, NSError *error) {
        NSError *serializationError = nil;
        NSMutableArray *commentArray =  [[NSMutableArray alloc] init];
        if (!error){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&serializationError];
        
            
        
            for (NSDictionary *child in json[@"data"][@"children"]){
                Comment *comment = [[Comment alloc] initWithDictionary:child[@"data"]];
                [commentArray addObject:comment];
            }
        }
        
        completion(commentArray, error);
        
    }];
}

/*
 * API Endpoint: /prefs/friends
 # Method: GET
 *
 * completion: Code block to deal with NSArray of User objects created by request
 */
- (void) getFriendsWithCompletion:(NSArrayHandler)completion{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/prefs/friends.json",BaseURL];
    
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    [self makeAPIRequestWithURL:url Method:@"GET" WithCompletion:^(NSData *data, NSError *error){
        
        
        NSError *serializationError = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&serializationError];
        
        //First item of the array is the friends listing
        NSDictionary *json = jsonArray[0];
        
        NSMutableArray *userArray =  [[NSMutableArray alloc] init];
        
        for(NSDictionary *child in json[@"data"][@"children"]){
            User *friend = [[User alloc] initWithName:child[@"name"]];
            [userArray addObject:friend];
        }
        completion(userArray, error);

    }];
}

/*
 * API Endpoint: /api/v1/me/friends/{userName}
 # Method: PUT
 *
 * userName: A valid user on reddit
 */
- (void) addFriendWithName:(NSString *)userName{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/v1/me/friends/%@",BaseURL,userName];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    NSString *jsonString = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\"}",userName];
    
    NSData *sendData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self makeAPIRequestWithURL:url Method:@"PUT" SendData:sendData WithCompletion:^(NSData *data, NSError *error){
        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
}

/*
 * API Endpoint: /api/v1/me/friends/{userName}
 # Method: DELETE
 *
 * userName: A valid user on reddit
 */
- (void) removeFriendWithName: (NSString *)userName{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/v1/me/friends/%@",BaseURL,userName];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    [self makeAPIRequestWithURL:url Method:@"DELETE" SendData:nil WithCompletion:^(NSData *data, NSError *error){
        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}


/*
 * API Endpoint: /api/comment
 * Method: POST
 *
 * postID: A valid post or comment ID
 * commentText: Raw markdown comment text
 */
- (void) replyToPostWithID:(NSString *)postID WithText:(NSString *)commentText{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/comment",BaseURL];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    jsonDict[@"api_type"] = @"json";
    jsonDict[@"text"] = commentText;
    jsonDict[@"thing_id"] = [[NSString alloc] initWithFormat:@"t1_%@",postID];
    
    NSError *serializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&serializationError];
    NSLog([[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    [self makeAPIRequestWithURL:url Method:@"POST" SendData:jsonData WithCompletion:^(NSData *data, NSError *error) {
        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
}

/*
 * API Endpoint: /api/vote
 * Method: POST
 *
 * postID: A valid post or comment ID
 * InDirection: Direction of vote, 1 = upvote, -1 = downvote, 0 = uncast vote
 */
- (void) castVoteForPostWithID: (NSString *)postID InDirection: (int) voteDirection{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/vote",BaseURL];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    jsonDict[@"dir"] = [[NSString alloc] initWithFormat:@"%d", voteDirection];
    jsonDict[@"id"] = postID;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    [self makeAPIRequestWithURL:url Method:@"POST" SendData:jsonData WithCompletion:^(NSData *data, NSError *error) {
        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
}

@end
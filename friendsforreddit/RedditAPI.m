//
//  RedditAPI.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "RedditAPI.h"
#import "Constants.h"
#import "GSKeychain.h"

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
 */
- (void) makeAPIRequestWithURL:(NSURL *) url
                        Method:(NSString *) method
                      SendData:(NSData *) sendData
                WithCompletion:(NSDataHandler) completion {
    

    accessToken = [[GSKeychain systemKeychain] secretForKey:@"access_token"];
    //Set up the HTTP request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url] ;
    NSString *bearerToken = [[NSString alloc] initWithFormat:@"bearer %@", accessToken];
    [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [request setValue:UserAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod: method];
    
    //Attach JSON data if present
    if (sendData){
        [request setHTTPBody: sendData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
#ifdef DEBUG
    NSLog(@"Making API request to reddit\n URL: %@", [url absoluteString]);
#endif
    
    //Create data session
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                                        
                                        //Check for errors
                                        if (error){
                                            NSLog(@"Error connecting to Reddit");
                                            
                                        } else {
                                            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *) response;
                                            NSLog(@"Request Succesful, HTTP response code %ld", urlResponse.statusCode);
                                            
                                            if (urlResponse.statusCode == 401){
                                                //Bad Authorization, refresh token
                                            } else if (urlResponse.statusCode >= 400 ) {
                                                //Create an error if HTTP status code is an error code
                                                error = [NSError errorWithDomain:@"HTTP Error"
                                                                            code:urlResponse.statusCode
                                                                        userInfo:@{@"response":response}];
                                            }
                                            
                                        }
                                        
                                        completion(data, error);
                                    }];
    //Run data session
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
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/r/friends/.json",BaseURL];
    
    
    if (postId){
        [urlString appendFormat:@"?count=%d&after=t3_%@",ObjectsPerRequest, postId];
    }
    
    
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
        
        //Load in images for these posts (should probably figure out a better strategy than this)
        for(Post *post in postArray){
            NSString *thumbUrl = post.thumbnail_url.absoluteString;
            //NSLog(@"Post Title %@ | Post Thumb: %@", post.link_title, thumbUrl);
            if ([thumbUrl isEqual: @"default"] || [thumbUrl isEqual: @"self"] || [thumbUrl isEqual: @""]) {
                post.thumbnail = [UIImage imageNamed:@"post_default_image.png"];
            }
            else if ([thumbUrl isEqual: @"nsfw"]) {
                post.thumbnail = [UIImage imageNamed:@"post_nsfw_image.png"];
            }
            else {
                NSData *thumbnailData = [NSData dataWithContentsOfURL:post.thumbnail_url];
                post.thumbnail = [UIImage imageWithData:thumbnailData scale:1.75];
            }
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
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@r/friends/comments",BaseURL];
    
    if (commentId){
        [urlString appendFormat:@"/?count=%d&after=t1_%@",ObjectsPerRequest, commentId];
    }
    
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
 * API Endpoint: /comments/{article}
 *
 * post: a comment or post object to fetch the replies for
 */
-(void) getCommentTree:(id)post Completion:(NSErrorHandler)completion{
    if ([post isKindOfClass:[Comment class]]){
        Comment *comment = (Comment *)post;
        NSString *urlString = [[NSString alloc] initWithFormat:@"%@comments/%@", BaseURL, [comment getRawLinkID]];

        //Construct query parameters
        NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
        NSURLQueryItem *commentID = [NSURLQueryItem queryItemWithName:@"comment" value:comment.comment_id];
        
        components.queryItems = @[ commentID ];
        NSURL *url = components.URL;

        [self makeAPIRequestWithURL:url Method:@"GET" WithCompletion:^(NSData *data, NSError *error){
            if(!error){
                NSError *serializationError = nil;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&serializationError];
                
                
                NSDictionary *thisPostJson = jsonArray[1][@"data"][@"children"][0][@"data"];
                
                //If replies key is a string then there are no replies
                if (![[thisPostJson objectForKey:@"replies"] isKindOfClass:[NSString class]]){
                
                    NSArray *repliesArray = thisPostJson[@"replies"][@"data"][@"children"];
                
                    [comment populateRepliesWithArray:repliesArray];

                }
            }
            completion(error);
        }];
        
        
    }
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
        
        NSMutableArray *userArray =  [[NSMutableArray alloc] init];
        if(!error){
            NSError *serializationError = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&serializationError];
            
            //First item of the array is the friends listing
            NSDictionary *json = jsonArray[0];
            

            //Create the friend objects
            for(NSDictionary *child in json[@"data"][@"children"]){
                User *friend = [[User alloc] initWithName:child[@"name"]];
                [userArray addObject:friend];
            }
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
- (void) addFriendWithName:(NSString *)userName OnError:(NSErrorHandler)errorHandler{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/v1/me/friends/%@",BaseURL,userName];
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
    NSString *jsonString = [[NSString alloc] initWithFormat:@"{\"name\":\"%@\"}",userName];
    
    NSData *sendData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self makeAPIRequestWithURL:url Method:@"PUT" SendData:sendData WithCompletion:^(NSData *data, NSError *error){
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        if (error){
            errorHandler(error);
        }
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
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}


/*
 * API Endpoint: /api/comment
 * Method: POST
 *
 * postID: A valid post or comment ID
 * commentText: Raw markdown comment text
 */
- (void) replyToPostWithID:(NSString *)postID
                      Type:(NSString *)parentType
                  WithText:(NSString *)commentText
                   OnError:(NSErrorHandler)errorHandler{
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@api/comment",BaseURL];
    
    NSString *typeIdentifier;
    
    //Resolve fullname thing type
    if ([parentType isEqualToString:@"Comment"]){
        typeIdentifier =@"t1";
    } else {
        typeIdentifier = @"t3";
    }
    
    NSString *fullThingName = [[NSString alloc] initWithFormat:@"%@_%@", typeIdentifier, postID];
    
    //Construct query parameters
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    NSURLQueryItem *api_type = [NSURLQueryItem queryItemWithName:@"api_type" value:@"json"];
    NSURLQueryItem *thing_id = [NSURLQueryItem queryItemWithName:@"thing_id" value:fullThingName];
    NSURLQueryItem *text = [NSURLQueryItem queryItemWithName:@"text" value:commentText];
    components.queryItems = @[ api_type, thing_id, text ];
    NSURL *url = components.URL;
    
    
    [self makeAPIRequestWithURL:url Method:@"POST" WithCompletion:^(NSData *data, NSError *error) {
        if (error){
            errorHandler(error);
        }
    }];
    
}

/*
 * API Endpoint: /api/vote
 * Method: POST
 *
 * postID: A valid post or comment ID
 * InDirection: Direction of vote, 1 = upvote, -1 = downvote, 0 = uncast vote
 */
- (void) castVoteForPostWithID: (NSString *)postID Type:(NSString *)postType InDirection: (int) voteDirection{
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@api/vote",BaseURL];
    
    NSString *typeIdentifier;
    
    //Resolve fullname thing type
    if ([postType isEqualToString:@"Comment"]){
        typeIdentifier =@"t1";
    } else {
        typeIdentifier = @"t3";
    }

    [urlString appendFormat:@"?dir=%d&id=%@_%@", voteDirection, typeIdentifier, postID];
    
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    
   
    [self makeAPIRequestWithURL:url Method:@"POST" WithCompletion:^(NSData *data, NSError *error) {}];
    
}


@end

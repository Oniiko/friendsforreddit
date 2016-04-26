//
//  Constants.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const BaseURL; //For making API calls via OAuth once logged in
extern NSString * const ClientID; //Our client ID
extern NSString * const BaseAuthorizationURL; //For redirecting user to authorization site
extern NSString * const BaseAccessURL; //For obtaining an access token
extern NSString * const UserAgent;
extern int const ObjectsPerRequest;


@end

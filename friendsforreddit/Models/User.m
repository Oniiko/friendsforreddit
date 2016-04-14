//
//  User.m
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;

-(id) initWithName:(NSString *)name{
    self = [super init];
    
    if (!self)
        return nil;
    
    username = name;
    
    
    return self;
}

@end

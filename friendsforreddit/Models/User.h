//
//  User.h
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/5/16.
//  Copyright (c) 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

    @property (nonatomic, strong, readonly) NSString *username;
    @property (nonatomic, assign, readonly) NSInteger commentKarma;
    @property (nonatomic, assign, readonly) NSInteger linkKarma;

    //If friends with logged-in user
    @property (nonatomic, assign, readonly, getter = isFriend) BOOL friend;

@end

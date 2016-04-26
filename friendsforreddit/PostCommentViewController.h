//
//  PostCommentViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/26/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditAPI.h"

@interface PostCommentViewController : UIViewController

@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentType;
@property (weak, nonatomic) IBOutlet UITextView *commentText;


@end

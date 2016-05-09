//
//  PostDetailViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/26/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditAPI.h"

@interface PostDetailViewController : UIViewController

@property (nonatomic) Post *post;
@property (nonatomic) NSMutableArray *comments;

@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *subreddit;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UITextView *postText;

@end

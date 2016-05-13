//
//  CommentTreeViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 5/11/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditAPI.h"

@interface CommentTreeViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>


@property (nonatomic) Comment *post;
@property (nonatomic) NSArray *comments;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *colorMapping;

@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UITextView *commentText;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthor;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *subreddit;

@end

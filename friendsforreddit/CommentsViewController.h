//
//  SecondViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTableViewCell.h"
#import "RedditAPI.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *comments;

@end


//
//  FriendsViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditAPI.h"

@interface FriendsViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property NSMutableArray *friends;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *username;

@end

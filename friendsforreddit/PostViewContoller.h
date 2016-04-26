//
//  PostViewContoller.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/21/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostTableViewCell.h"

@interface PostViewContoller : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *posts;

@end

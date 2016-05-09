//
//  PostDetailViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/26/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "PostDetailViewController.h"

@interface PostDetailViewController ()
@property RedditAPI *api;
@end

@implementation PostDetailViewController

@synthesize post;
@synthesize postTitle;
@synthesize postText;
@synthesize userName;
@synthesize timestamp;
@synthesize subreddit;
@synthesize score;
@synthesize comments;
@synthesize api;

- (void)viewDidLoad {
    [super viewDidLoad];
    postTitle.text = post.link_title;
    userName.text = post.author;
    subreddit.text = [[NSString alloc] initWithFormat:@"/r/%@",post.subreddit];
    score.text = [[NSString alloc] initWithFormat:@"Score: %lu", post.score];
    timestamp.text = [NSDateFormatter localizedStringFromDate: post.created
                                                    dateStyle:NSDateFormatterMediumStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    postText.text = post.selftext;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

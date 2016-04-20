//
//  SecondViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "CommentsViewController.h"
#import "SVPullToRefresh/UIScrollView+SVInfiniteScrolling.h"

@interface CommentsViewController ()
@property RedditAPI *api;
@property (nonatomic) BOOL loadingData;
@end

@implementation CommentsViewController

@synthesize comments;
@synthesize tableView;
@synthesize api;
@synthesize loadingData;


- (void)viewDidLoad {
    [super viewDidLoad];
    api = [RedditAPI sharedRedditAPI];
    self.comments = [[NSMutableArray alloc] init];
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadComments];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^(void){
        [weakSelf loadComments];
    }];
    
}


- (void) loadComments{
    self.loadingData = YES;
    NSString *lastCommentID = [self.comments.lastObject comment_id];
    NSLog(@"last commentID: %@", lastCommentID);
    
    [api getCommentsAfterCommentID:lastCommentID InOrder:@"HOT" Completion:^(NSArray *returnedFriends, NSError *error){

        NSLog([error localizedDescription]);
        
        //No more data, stop infinite scrolling
        if (returnedFriends.count == 0){
            self.tableView.showsInfiniteScrolling = NO;
            return;
        }
        
        [comments addObjectsFromArray:returnedFriends];
        
        //Reload data on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
    
    self.loadingData = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comments count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier =@"commentCell";
    
    CommentTableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.postTitle.text = [[self.comments objectAtIndex:indexPath.row] link_title];
    cell.commentText.text = [[self.comments objectAtIndex:indexPath.row] body];
    cell.commentAuthor.text = [[self.comments objectAtIndex:indexPath.row] author];
    cell.subreddit.text = [[NSString alloc] initWithFormat:@"/r/%@", [[self.comments objectAtIndex:indexPath.row] subreddit]];

    

    
    return cell;
}

@end

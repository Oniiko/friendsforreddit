//
//  CommentTreeViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 5/11/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "CommentTreeViewController.h"
#import "CommentReplyTableViewCell.h"

@interface CommentTreeViewController ()

@end

@implementation CommentTreeViewController

@synthesize post;
@synthesize comments;
@synthesize tableView;
@synthesize postTitle;
@synthesize commentAuthor;
@synthesize commentText;
@synthesize score;
@synthesize subreddit;
@synthesize colorMapping;

- (void)viewDidLoad {
    [super viewDidLoad];
    RedditAPI *api = [RedditAPI sharedRedditAPI];
    //Set automatic cell sizing
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.postTitle.text = post.link_title;
    self.commentText.text = post.body;
    self.commentAuthor.text = post.author;
    self.subreddit.text = post.subreddit;
    self.score.text = [[NSString alloc] initWithFormat:@"%lu", post.score];
    self.timestamp.text = [NSDateFormatter localizedStringFromDate: post.created
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    [api getCommentTree:post Completion:^(NSError * error){
        if (!error){
            comments = [post getFlattenedCommentTree];
            NSLog(@"Comment count: %lu", [comments count]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
        }
    }];
    colorMapping = [[NSMutableArray alloc] init];

    colorMapping[0] = [UIColor blackColor];
    colorMapping[1] = [UIColor blueColor];
    colorMapping[2] = [UIColor redColor];
    colorMapping[3] = [UIColor greenColor];
    colorMapping[4] = [UIColor orangeColor];
    colorMapping[5] = [UIColor purpleColor];
    colorMapping[6] = [UIColor yellowColor];



}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [comments count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = [self.comments objectAtIndex:indexPath.row];

    return comment.depth;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier =@"commentReplyCell";
    
    CommentReplyTableViewCell *cell = [tableView
                                  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CommentReplyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Skip over first comment which is the parent
    Comment *comment = [self.comments objectAtIndex:(indexPath.row)];
    
    
    //Populate cell fields
    cell.commentAuthor.text = comment.author;
    cell.commentText.text = comment.body;
    cell.indentColor.backgroundColor = colorMapping[comment.depth % ([colorMapping count] - 1)];

    //Set cell background according to user's vote on the comment
    if (comment.vote == 1){
        UIColor *upvoteColor = [UIColor colorWithRed:1 green:139.0/255.0 blue:96.0/255.0 alpha:0.5];
        cell.backgroundColor = upvoteColor;
    } else if (comment.vote == -1){
        UIColor *downvoteColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:1 alpha:0.5];
        cell.backgroundColor = downvoteColor;
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;
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

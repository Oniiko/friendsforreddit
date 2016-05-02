//
//  SecondViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "CommentsViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "PostCommentViewController.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface CommentsViewController ()
@property RedditAPI *api;
@property (nonatomic) BOOL reloadData;
@end

@implementation CommentsViewController

@synthesize comments;
@synthesize tableView;
@synthesize api;
@synthesize reloadData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize the api and start loading comments
    api = [RedditAPI sharedRedditAPI];
    self.comments = [[NSMutableArray alloc] init];
    [self loadComments];
    
    
    //Set automatic cell sizing
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Add left and right swipe gestures
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
    
    
    //Set up infinite scrolling
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^(void){
        [weakSelf loadComments];
    }];
    
    //Set up pull to refrseh
    [self.tableView addPullToRefreshWithActionHandler:^(void){
        weakSelf.reloadData = YES;
        [weakSelf loadComments];
    }];
    
}

/*
 * Upvotes the swiped comment and changes the cell background
 */
- (void) handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer{
    NSLog(@"user swept left");
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    Comment *swipedComment = comments[indexPath.row];
    if (swipedComment.vote != 1){
        swipedComment.vote = 1;
        [api castVoteForPostWithID:swipedComment.comment_id Type:@"Comment" InDirection:1];
        
        UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
        UIColor *upvoteColor = [UIColor colorWithRed:1 green:139.0/255.0 blue:96.0/255.0 alpha:0.5];
        cell.backgroundColor = upvoteColor;
    }

}

/*
 * Downvotes the swiped comment and changes the cell background
 */
- (void) handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer{
    NSLog(@"user swept right");
    
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    Comment *swipedComment = comments[indexPath.row];
    if (swipedComment.vote != -1){
        swipedComment.vote = -1;
        [api castVoteForPostWithID:swipedComment.comment_id Type:@"Comment" InDirection:-1];
        
        UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
        UIColor *downvoteColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:1 alpha:0.5];
        cell.backgroundColor = downvoteColor;
    }
}

/*
 * Display generic error message with error code
 */
- (void) displayErrorMessageForError: (NSError *) error{
    NSString *errorMessage = [[NSString alloc] initWithFormat:@"Something went wrong\nError Code:%ld", [error code]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void) loadComments{

    NSString *lastCommentID =nil;
    if (!reloadData){
        lastCommentID = [self.comments.lastObject comment_id];
    }

    [api getCommentsAfterCommentID:lastCommentID InOrder:@"HOT" Completion:^(NSArray *returnedComments, NSError *error){

        NSLog([error localizedDescription]);
        
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayErrorMessageForError:error];
            });
            
            return;
            
        }
        
        //No more data, stop infinite scrolling
        if (returnedComments.count == 0){
            self.tableView.showsInfiniteScrolling = NO;
            return;
        }
        
        //If reloading data then remove everything currently in the array
        if (reloadData){
            [self.comments removeAllObjects];
            self.reloadData = NO;
        }
        
        [comments addObjectsFromArray:returnedComments];
        
        //Stop any loading animations
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
        
        //Reload data on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });

    }];
    

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
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    
    //Populate cell fields
    cell.postTitle.text = comment.link_title;
    cell.commentText.text = comment.body;
    cell.commentAuthor.text = comment.author;
    cell.subreddit.text = [[NSString alloc] initWithFormat:@"/r/%@",  comment.subreddit];
    
    cell.timestamp.text = [NSDateFormatter localizedStringFromDate: comment.created
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
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

    //Set up long press gesture
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:lpgr];
    
    return cell;
}


/*
 * Present user option to reply to post
 */
-(void) handleLongPress: (UILongPressGestureRecognizer *) gestureRecognizer{
    
    NSString *message = @"Would you like to reply to this comment?";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reply?"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self performSegueWithIdentifier:@"ReplyCommentSegue" sender:self];
                                                      }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    long index = [self.tableView indexPathForSelectedRow].row;

    
    //If segue to postcomment view then pass the parent comment info
    if ([segue.destinationViewController isKindOfClass:[PostCommentViewController class]]){
        PostCommentViewController *postCommentView = segue.destinationViewController;
        postCommentView.parentId = [comments[index] comment_id];
        postCommentView.parentType = @"Comment";
    }
}

@end

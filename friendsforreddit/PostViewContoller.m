//
//  PostViewContoller.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/21/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "PostViewContoller.h"
#import "RedditAPI.h"
#import "PostWebViewController.h"
#import "PostCommentViewController.h"
#import "PostDetailViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface PostViewContoller ()
@property RedditAPI *api;
@property BOOL reloadData;

@end

@implementation PostViewContoller

@synthesize posts;
@synthesize api;
@synthesize tableView;
@synthesize reloadData;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *redditBlue = [UIColor colorWithRed:206.0/255.0 green:227.0/255.0 blue:248.0/255.0 alpha:1];
    [[UINavigationBar appearance] setBarTintColor:redditBlue];
    
    //Initialize objects and start loading posts
    self.posts = [[NSMutableArray alloc] init];
    api = [RedditAPI sharedRedditAPI];
    [self loadPosts];
    
    //Set up swipe gestures
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
    
    //Set automatic cell sizing
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    //Set up infinite scrolling
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^(void){
        [weakSelf loadPosts];
    }];
    
    [self.tableView addPullToRefreshWithActionHandler:^(void){
        weakSelf.reloadData = YES;
        [weakSelf loadPosts];
    }];
}

/*
 * Displays a generic error message with the corresponding error code
 */
- (void) displayErrorMessageForError:(NSError *) error{
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


/*
 * Loads a set of post objects retrieved from reddit into the local posts array via async api call
 * If the array already contains posts, loads the set of posts following the last post
 * currently in the posts array
 */
- (void) loadPosts{
    NSString *lastPostID;
    if (reloadData){
        lastPostID = nil;
    } else {
        lastPostID = [self.posts.lastObject post_id];
    }
    
    [api getPostsAfterPostID:lastPostID InOrder:@"HOT" Completion:^(NSArray *returnedPosts, NSError *error){
        
        NSLog([error localizedDescription]);
        
        //Alert user if there is an error (most likely lost data connection)
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayErrorMessageForError:error];
            });
            return;
            
        }
        
        //No more data, stop infinite scrolling
        if (returnedPosts.count == 0){
            self.tableView.showsInfiniteScrolling = NO;
            return;
        }
        
        if (reloadData){
            [self.posts removeAllObjects];
            self.reloadData = NO;
        }

        
        [posts addObjectsFromArray:returnedPosts];
        
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
        
        //Reload data on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        

        
    }];
}

/*
 * Upvotes the swiped comment and changes the cell background
 */
- (void) handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer{
    NSLog(@"user swept left");
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    Post *swipedPost = posts[indexPath.row];
    if (swipedPost.vote != 1){
        swipedPost.vote = 1;
        [api castVoteForPostWithID:swipedPost.post_id Type:@"Comment" InDirection:1];
        
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
    
    Post *swipedPost = posts[indexPath.row];
    
    //Don't do anything if post is already downvoted
    if (swipedPost.vote != -1){
        swipedPost.vote = -1;
        [api castVoteForPostWithID:swipedPost.post_id Type:@"Link" InDirection:-1];
        
        UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
        UIColor *downvoteColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:1 alpha:0.5];
        cell.backgroundColor = downvoteColor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.posts count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier =@"postCell";
    
    PostTableViewCell *cell = [tableView
                                  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Post *post = [self.posts objectAtIndex:indexPath.row];
    
    //Set cell fields
    cell.title.text = post.link_title;
    cell.postAuthor.text = post.author;
    cell.subreddit.text = [[NSString alloc] initWithFormat:@"/r/%@", post.subreddit];
    cell.thumbnail.image = post.thumbnail;
    cell.timestamp.text = [NSDateFormatter localizedStringFromDate: post.created
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    
    if (post.vote == 1){
        UIColor *upvoteColor = [UIColor colorWithRed:1 green:139.0/255.0 blue:96.0/255.0 alpha:0.5];
        cell.backgroundColor = upvoteColor;
    } else if (post.vote == -1){
        UIColor *downvoteColor = [UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:1 alpha:0.5];
        cell.backgroundColor = downvoteColor;
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    lpgr.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:lpgr];
    
    return cell;
}


/*
 * Present user option to reply to post
 */
-(void) handleLongPress: (UILongPressGestureRecognizer *) gestureRecognizer{
    
    NSString *message = @"Would you like to reply to this post?";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reply?"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self performSegueWithIdentifier:@"PostCommentSegue" sender:self];
                                                      }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    long index = [self.tableView indexPathForSelectedRow].row;

    //Switch between webview for external links and post detail for self posts
    if ([posts[index] isSelfPost]){
        [self performSegueWithIdentifier:@"PostDetailSegue" sender:self];
    } else {
        NSLog(@"Segue to webview");
        [self performSegueWithIdentifier:@"PostWebViewSegue" sender:self];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    long index = [self.tableView indexPathForSelectedRow].row;
    
    if ([posts[index] isSelfPost]){
        NSLog(@"is self post");
    } else {
        NSLog(@"not self post");
    }
    
    //Figure out where we're going and pass information needed
    if ([segue.destinationViewController isKindOfClass:[PostWebViewController class]]){
        PostWebViewController *webView = segue.destinationViewController;
        webView.destination = [posts[index] url];
    } else if ([segue.destinationViewController isKindOfClass:[PostCommentViewController class]]){
        PostCommentViewController *postCommentView = segue.destinationViewController;
        postCommentView.parentId = [posts[index] post_id];
        postCommentView.parentType = @"Post";
    } else if ([segue.destinationViewController isKindOfClass:[PostDetailViewController class]]){
        PostDetailViewController *postDetailView = segue.destinationViewController;
        postDetailView.post = posts[index];
    }

}


@end

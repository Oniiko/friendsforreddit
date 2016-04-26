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
#import "UIScrollView+SVInfiniteScrolling.h"

@interface PostViewContoller ()
@property RedditAPI *api;

@end

@implementation PostViewContoller

@synthesize posts;
@synthesize api;
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    self.posts = [[NSMutableArray alloc] init];
    api = [RedditAPI sharedRedditAPI];
    
    
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadPosts];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^(void){
        [weakSelf loadPosts];
    }];
}

- (void) displayErrorMessageForError:(NSError *) error{
    
}

- (void) loadPosts{
    NSString *lastPostID = [self.posts.lastObject post_id];
    
    [api getPostsAfterPostID:lastPostID InOrder:@"HOT" Completion:^(NSArray *returnedPosts, NSError *error){
        
        NSLog([error localizedDescription]);
        
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
        
        [posts addObjectsFromArray:returnedPosts];
        
        //Reload data on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        
        [self.tableView.infiniteScrollingView stopAnimating];
        
    }];
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
    
    cell.title.text = [[self.posts objectAtIndex:indexPath.row] link_title];
    cell.postAuthor.text = [[self.posts objectAtIndex:indexPath.row] author];
    cell.subreddit.text = [[NSString alloc] initWithFormat:@"/r/%@", [[self.posts objectAtIndex:indexPath.row] subreddit]];
    
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
        //segue to post detail
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
    }

}


@end

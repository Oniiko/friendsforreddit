//
//  PostCommentViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/26/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "PostCommentViewController.h"

@interface PostCommentViewController ()

@end

@implementation PostCommentViewController

@synthesize parentId;
@synthesize commentText;
@synthesize parentType;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO; //Make typing start at the top
    }

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.commentText becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hitPostButton:(id)sender {
    
    [self postComment];
}

/* API call to post a comment to Reddit
 *
 *
*/
- (void) postComment{
    RedditAPI *api = [RedditAPI sharedRedditAPI];
    
    [api replyToPostWithID: self.parentId
                      Type: self.parentType
                  WithText: self.commentText.text
                   OnError:^(NSError *error){
                       //TODO: Show error message
                       return;
        
    }];
    
    [self.navigationController popViewControllerAnimated:YES];

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

//
//  FriendsViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/12/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

@synthesize friends;
@synthesize tableView;

RedditAPI *api;

- (void)viewDidLoad {
    [super viewDidLoad];
    api = [RedditAPI sharedRedditAPI];
    self.friends = [[NSMutableArray alloc] init];
    

}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadFriends];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 * Make asynchronus API request for friends, replace any entries in friends array, reload table
 */
- (void) loadFriends{
    [api getFriendsWithCompletion:^(NSArray *returnedFriends, NSError *error){

        
        //TODO: display error message
        if (error){
            NSLog([error localizedDescription]);
            return;
        }
        
        [friends removeAllObjects];
        [friends addObjectsFromArray:returnedFriends];
        
        //Reload data on the UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.friends count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier =@"simpleidentifier";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    lpgr.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:lpgr];
    cell.textLabel.text=[[self.friends objectAtIndex:indexPath.row] username];
    
    return cell;
}

/*
 * Handle user pressing and holding a cell. Present option to delete friend
 */
-(void) handleLongPress: (UILongPressGestureRecognizer *) gestureRecognizer{
    
    
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    User *user = friends[indexPath.row];
    
    NSLog(@"handling long press for  row %ld", (long)indexPath.row);
    
    NSString *message = [[NSString alloc] initWithFormat:@"Would you like to remove %@ from your friends list?", user.username];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove Friend?"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [api removeFriendWithName: user.username];
                                                          
                                                          [self loadFriends];
                                                      }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){}];
    
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
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

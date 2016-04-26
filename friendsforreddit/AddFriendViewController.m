//
//  AddFriendViewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/26/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

@synthesize userName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFriend:(id)sender {
    RedditAPI *api =  [RedditAPI sharedRedditAPI];
    
    [api addFriendWithName: userName.text OnError:^(NSError *error){
        if (error.code == 400){
            NSString *errorMessage = @"Invalid User Name";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:errorMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){}];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
    }];
    
    
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

//
//  LogInviewController.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "LogInViewController.h"
#import "GSKeychain.h"
#import "RedditAPI.h"

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIColor *redditBlue = [UIColor colorWithRed:206.0/255.0 green:227.0/255.0 blue:248.0/255.0 alpha:1];
    [[UINavigationBar appearance] setBarTintColor:redditBlue];
    //[[GSKeychain systemKeychain] removeSecretForKey:@"access_token"];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[GSKeychain systemKeychain] secretForKey:@"refresh_token"]) {
        [self performSegueWithIdentifier:@"loggedInSegue" sender:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

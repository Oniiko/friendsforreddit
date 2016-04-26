//
//  ModalWebViewController.m
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "ModalWebViewController.h"
#import "Constants.h"

@implementation ModalWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView.delegate = self;
    [self loadUIWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // Close modal view when there's an error
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
/*
* Prompts the user to login to Reddit and give permission to FriendsForReddit
*/
- (void)loadUIWebView {
    NSURL *authorizationURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@?client_id=%@&response_type=code&state=TEST&redirect_uri=friendsforreddit://response&duration=permanent&scope=%@", BaseAuthorizationURL, ClientID, @"subscribe+read+vote+submit"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:authorizationURL];
    [self.webView loadRequest:request];
}

@end
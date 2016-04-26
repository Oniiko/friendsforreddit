//
//  PostWebViewController.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/25/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostWebViewController : UIViewController

@property NSURL *destination;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

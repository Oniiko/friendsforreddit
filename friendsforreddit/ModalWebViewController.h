//
//  ModalWebViewController.h
//  friendsforreddit
//
//  Created by Nicholas Wen on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalWebViewController : UIViewController
{
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)loadUIWebView;

@end


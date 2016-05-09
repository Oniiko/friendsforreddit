//
//  AppDelegate.m
//  friendsforreddit
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "GSKeychain.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

/*
* Processes the return url from ModalWebView
*
* Sends additional request for authentication and refresh tokens
*/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqualToString:@"friendsforreddit"]) {
        NSArray *queryParams = [[url query] componentsSeparatedByString:@"&"];
        NSArray *codeParam = [queryParams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", @"code="]];
        NSString *codeQuery = [codeParam objectAtIndex:0];
        NSString *code = [codeQuery stringByReplacingOccurrencesOfString:@"code=" withString:@""];
        NSLog(@"My code is %@", code);

        // Make HTTP request for access token
        NSURL *authURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@", BaseAccessURL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authURL];
        NSString *postParams = [NSString stringWithFormat: @"grant_type=authorization_code&code=%@&redirect_uri=%@", code, @"friendsforreddit://response"];
        
        //Encode Basic Authentication Header
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", ClientID, @""];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        
        //Set HTTP header values
        [request setValue:[NSString stringWithFormat: @"%@", authValue] forHTTPHeaderField: @"Authorization"];
        [request setValue:UserAgent forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        //Set HTTP Method and Body
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postParams dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Send request to get access token
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (error){
                                              NSLog(@"Error");
                                          } else {
                                              NSLog(@"Request Successful");
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingAllowFragments
                                                                                                     error:nil];                                              
                                              
                                              [[GSKeychain systemKeychain] setSecret:json[@"access_token"] forKey:@"access_token"];
                                              
                                              [[GSKeychain systemKeychain] setSecret:json[@"refresh_token"] forKey:@"refresh_token"];
                                              /**
                                              if ([[GSKeychain systemKeychain] secretForKey:@"access_token"]) {
                                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                  UITabBarController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
                                                  [(UINavigationController*)self.window.rootViewController pushViewController:ivc animated:NO];
                                              }
                                               **/
                                             
                                          }
                                      }];
        
        [task resume];

        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  CommentReplyTableViewCell.h
//  friendsforreddit
//
//  Created by Gregory Johnson on 5/11/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentReplyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel*commentText;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthor;
@property (weak, nonatomic) IBOutlet UIView *indentColor;

@end

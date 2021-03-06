//
//  MyLeafView.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PSBaseLeafView.h"


@interface CustomLeafView : PSBaseLeafView

@property (nonatomic, weak) IBOutlet UIButton *expandButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *showProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *showStatsButton;

@end

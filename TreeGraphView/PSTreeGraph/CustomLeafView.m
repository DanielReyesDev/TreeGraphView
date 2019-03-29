//
//  MyLeafView.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2015 Preston Software. All rights reserved.
//


#import "CustomLeafView.h"



@implementation CustomLeafView


#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.25;
        self.layer.shadowRadius = 15;
        self.layer.shadowOffset = CGSizeMake(0, 10);
        
        
        // Initialization code, leaf views are always loaded from the corresponding XIB.
        // Be sure to set the view class to your subclass in interface builder.

        // Example: Inverse the color scheme
        //self.selectionColor = [UIColor lightGrayColor];
        //self.borderColor = [UIColor lightGrayColor];
//        self.borderWidth = 0;
//        self.fillColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.00];
        
        

    }
    return self;
}


@end

//
//  EntryCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 30/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "EntryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EntryCell

@synthesize top, bottom, right, image, rightBottom, forLabel;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated]; 

    if (editing) {
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - right.frame.origin.x - right.bounds.size.width, 0);
                         } 
                         completion:^(BOOL fin) {
                             right.hidden = right.frame.origin.x < 0;
                         }];
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, - rightBottom.frame.origin.x - rightBottom.bounds.size.width, 0);
                             
                         } 
                         completion:^(BOOL fin) {
                             rightBottom.hidden = rightBottom.frame.origin.x < 0;
                         }];
        
        // beide labels ganz nach rechts ausdehnen
        self.bottom.frame = CGRectMake(self.bottom.frame.origin.x, self.bottom.frame.origin.y, self.contentView.frame.size.width - self.bottom.frame.origin.x, self.bottom.frame.size.height);
        self.top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.contentView.frame.size.width - self.top.frame.origin.x, self.top.frame.size.height);
        
    } else {
        
        rightBottom.hidden = NO;
        right.hidden = NO;
        
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             right.transform = CGAffineTransformIdentity;
                             right.hidden = NO;
                         } 
                         completion:^(BOOL fin) { 
                             [right setNeedsDisplay];  
                             right.hidden = right.frame.origin.x < 0;
                         }];  
        [UIView animateWithDuration:0.3
                              delay:0 
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             rightBottom.transform = CGAffineTransformIdentity;
                             rightBottom.hidden = NO;
                         } 
                         completion:^(BOOL fin) { 
                            [rightBottom setNeedsDisplay]; 
                             rightBottom.hidden = rightBottom.frame.origin.x < 0;

                         }];
        
        // beide labels wieder nach links
        self.bottom.frame = CGRectMake(self.bottom.frame.origin.x, self.bottom.frame.origin.y, self.rightBottom.frame.origin.x - self.bottom.frame.origin.x, self.bottom.frame.size.height);
        self.top.frame = CGRectMake(self.top.frame.origin.x, self.top.frame.origin.y, self.right.frame.origin.x - self.top.frame.origin.x, self.top.frame.size.height);
        
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.separatorInset = UIEdgeInsetsMake(0, 44, 0, 0);
}

- (void)dealloc {
    
    self.top = nil;
    self.bottom = nil;
    self.right = nil;
    self.image = nil;
    self.rightBottom = nil;
    self.forLabel = nil;
    
    [super dealloc];
}

@end

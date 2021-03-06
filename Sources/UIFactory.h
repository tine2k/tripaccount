//
//  UIFactory.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "HelpView.h"
#import "Crittercism.h"

#define NAVIGATIONBAR_HEIGHT 45
#define TABBAR_HEIGHT 50
#define ENTRY_SORT_HEIGHT 40
#define CURRENCY_SORT_HEIGHT 45
#define STATUSBAR_HEIGHT 20

#define RATE_SORT_TOOLBAR_HEIGHT 25
#define RATE_LABEL_HEIGHT 10
#define ACTIVITY_VIEW_SIZE 20

#define TOTAL_VIEW_HEIGHT 40

@class HelpView;

@interface UIFactory : NSObject {
    
}

+ (void)initializeTableViewController:(UITableView *)controller;
+ (void)initializeCell:(UITableViewCell *)cell;
+ (void)addGradientToView:(UIView *)cell;
+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2;
+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2 startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
+ (int)defaultSectionHeaderCellHeight;
+ (int)defaultCellHeight;
+ (void)addShadowToView:(UIView *)view;
+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color;
+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color withOffset:(double)offset andRadius:(double)radius;
+ (void)removeShadowFromView:(UIView *)view;
+ (BOOL)dateHasTime:(NSDate *)date;
+ (NSDate *)createDateWithoutTimeFromDate:(NSDate *)date;
+ (UIColor *)defaultTintColor;
+ (UIColor *)defaultDarkTintColor; 
+ (UIColor *)defaultLightTintColor;
+ (void)changeTextColorOfSegControler:(UISegmentedControl *)segControl color:(UIColor *)color;
+ (UIView *)createBackgroundViewWithFrame:(CGRect)rect;
+ (void)setColorOfSearchBarInABPicker:(ABPeoplePickerNavigationController *)picker color:(UIColor *)color;
+ (UIAlertView *)createAlterViewForRefreshingRatesOnOpeningTravel:(id <UIAlertViewDelegate>)delegate;
+ (NSString *)formatNumber:(NSNumber *)number;
+ (NSString *)formatNumber:(NSNumber *)number withDecimals:(int)decimals;
+ (NSString *)formatNumberWithoutThSep:(NSNumber *)number withDecimals:(int)decimals;
+ (void)addHelpViewToView:(HelpView *)helpView toView:(UIView *)view;
+ (void)replaceHelpViewInView:(NSString *)replaceHelpViewId withView:(HelpView *)helpView toView:(UIView *)view;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString *)translateString:(NSString *)dbString;
+ (UITableViewRowAnimation)commitEditingStyleRowAnimation;

@end

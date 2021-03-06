//
//  UIFactory.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 18/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "UIFactory.h"
#import <QuartzCore/QuartzCore.h>

@interface UIFactory ()

+ (void)setSearchBarColorRekursive:(UIView*)parent foundSearchBar:(BOOL)foundSearchBar color:(UIColor *)color;

@end

static NSDateFormatter *formatter = nil;

@implementation UIFactory

#define ct(x) (x / 256.0)

+ (UIColor *)defaultTintColor {
    return [UIColor colorWithRed:ct(159) green:ct(172) blue:ct(181) alpha:1];
}

+ (UIColor *)defaultDarkTintColor {
    //return [UIColor colorWithRed:ct(59) green:ct(72) blue:ct(81) alpha:1];
    return [UIColor colorWithRed:ct(99) green:ct(112) blue:ct(121) alpha:1];
}

+ (UIColor *)defaultLightTintColor {
    return [UIColor colorWithRed:ct(219) green:ct(232) blue:ct(241) alpha:1];
}

+ (UIView *)createBackgroundViewWithFrame:(CGRect)rect {
    UIView *backgroundView = [[[UIView alloc] initWithFrame:rect] autorelease];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    return backgroundView;
}

+ (void)setColorOfSearchBarInABPicker:(ABPeoplePickerNavigationController *)picker color:(UIColor *)color {
    
    [self setSearchBarColorRekursive:picker.view foundSearchBar:NO color:color];
}

+ (void)setSearchBarColorRekursive:(UIView*)parent foundSearchBar:(BOOL)foundSearchBar color:(UIColor *)color {
    
    for (UIView* view in [parent subviews]) {
        
        if (foundSearchBar) {
            return;
        }
        
        if ([view isKindOfClass:[UISearchBar class]]) {
            
            [(UISearchBar*)view  setTintColor:color];
            break;
        }
        
        [self setSearchBarColorRekursive:view foundSearchBar:foundSearchBar color:color];
    }
}

+ (UIAlertView *)createAlterViewForRefreshingRatesOnOpeningTravel:(id <UIAlertViewDelegate>)delegate {
    
    NSString *rateRefreshAlertViewMessage = NSLocalizedString(@"Do you want to assign the latest currency exchange rates to this travel?", @"when opening travel");
    return [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Refresh rates", @"alert view title") message:rateRefreshAlertViewMessage delegate:delegate cancelButtonTitle:NSLocalizedString(@"No", @"alert title answer") otherButtonTitles:NSLocalizedString(@"Yes", @"alert title answer"), nil] autorelease];
    
}


+ (void)changeTextColorOfSegControler:(UISegmentedControl *)segControl color:(UIColor *)color {
    
    int eg=0;
    for (id seg in [segControl subviews]) {
        
        int gg=segControl.selectedSegmentIndex;
        if(gg==2)
            gg=0;
        else if(gg==0)
            gg=2;
        
        if(eg==gg && eg!=1) {
            for (id label in [seg subviews]) {
                if ([label isKindOfClass:[UILabel class]]) {
                    [label setTextColor:color];
                }
            }
        } else if(eg==1) {
            for (id label in [seg subviews]) {
                if ([label isKindOfClass:[UILabel class]]) {
                    [label setTextColor:color];
                }
            }
        } else {
            for (id label in [seg subviews]) {
                if ([label isKindOfClass:[UILabel class]]) {
                    [label setTextColor:color];  
                }
            }
        }
        eg++;
    }
}

#pragma mark Shadow

+ (void)addShadowToView:(UIView *)view {
    
    [self addShadowToView:view withColor:[UIColor blackColor]];
}

+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color {
    
    [self addShadowToView:view withColor:color withOffset:1.0 andRadius:3.0];
}

+ (void)addShadowToView:(UIView *)view withColor:(UIColor *)color withOffset:(double)offset andRadius:(double)radius {
    
    view.layer.shadowColor = [color CGColor];
    view.layer.shadowOffset = CGSizeMake(offset, offset);
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = 1.0f;
    //view.layer.shouldRasterize = YES;
    //view.layer.masksToBounds = YES;
}

+ (void)removeShadowFromView:(UIView *)view {
    
    view.layer.shadowColor = [[UIColor clearColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = 0;
    view.layer.shadowOpacity = 0;
    view.layer.masksToBounds = YES;
    
}

#pragma mark Date

+ (BOOL)dateHasTime:(NSDate *)date {
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    }
    
    BOOL returnValue = ![[formatter stringFromDate:date] isEqualToString:@"00:00"];
    return returnValue;    
}

+ (NSDate *)createDateWithoutTimeFromDate:(NSDate *) date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit  | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSDate *returnDate = [gregorian dateFromComponents:dateComponents];
    [gregorian release];
    return returnDate;
}

#pragma mark TableViews and Cells

+ (void)initializeCell:(UITableViewCell *)cell {
    
    //    CAGradientLayer *gradient = [[CAGradientLayer layer] retain];
    //    gradient.frame = cell.bounds;
    //    gradient.startPoint = CGPointMake(0.5, 0.5);
    //    gradient.endPoint = CGPointMake(1, 1);
    //    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:1] CGColor], (id)[[UIColor colorWithWhite:0.8 alpha:1] CGColor], nil];
    //    gradient.needsDisplayOnBoundsChange = YES;
    //    
    //    cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width, cell.frame.size.height)] autorelease];
    //    [cell.backgroundView.layer insertSublayer:gradient atIndex:0];
    //    cell.backgroundView.contentMode = UIViewContentModeRedraw;
}

+ (void)initializeTableViewController:(UITableView *)view {
    
}

+ (int)defaultSectionHeaderCellHeight {
    return 22;
}

+ (int)defaultCellHeight {
    return 40;
}

#pragma mark Gradients

+ (void)addGradientToView:(UIView *)cell {
    
    CAGradientLayer *gradient = nil;
    if ([[cell.layer.sublayers objectAtIndex:0] isKindOfClass:[CAGradientLayer class]]) {
        gradient = [cell.layer.sublayers objectAtIndex:0];
    } else {
        gradient = [CAGradientLayer layer];
    }

    gradient.frame = cell.bounds;
    gradient.startPoint = CGPointMake(0.5, 0.5);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:1] CGColor], (id)[[UIColor colorWithWhite:0.8 alpha:1] CGColor], nil];
    gradient.needsDisplayOnBoundsChange = YES;

    [cell.layer insertSublayer:gradient atIndex:0];  
}

+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2 {
    
    CAGradientLayer *gradient = nil;
    if ([[cell.layer.sublayers objectAtIndex:0] isKindOfClass:[CAGradientLayer class]]) {
        gradient = [cell.layer.sublayers objectAtIndex:0];
    } else {
        gradient = [CAGradientLayer layer];
    }
    
    gradient.frame = cell.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    gradient.needsDisplayOnBoundsChange = YES;
    
    [cell.layer insertSublayer:gradient atIndex:0]; 
}

+ (void)addGradientToView:(UIView *)cell color1:(UIColor *)color1 color2:(UIColor *)color2 startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    
    [self addGradientToView:cell color1:color1 color2:color2];
    
    CAGradientLayer *gradient = [cell.layer.sublayers objectAtIndex:0];
    gradient.startPoint = startPoint;
    gradient.endPoint = endPoint;
    
}

+ (NSString *)formatNumber:(NSNumber *)number {
    return [self formatNumber:number withDecimals:2];
}

+ (NSString *)formatNumber:(NSNumber *)number withDecimals:(int)decimals {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = decimals;
    NSString *returnValue = [numberFormatter stringFromNumber:number];
    [numberFormatter release];
    
    return returnValue;
}

+ (NSString *)formatNumberWithoutThSep:(NSNumber *)number withDecimals:(int)decimals {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = NO;
    numberFormatter.maximumFractionDigits = decimals;
    NSString *returnValue = [numberFormatter stringFromNumber:number];
    [numberFormatter release];
    
    return returnValue;
}

+ (void)addHelpViewToView:(HelpView *)helpView toView:(UIView *)view {
       
    BOOL alreadyAdded = NO;
    for (UIView *subView in [view subviews]) {
        if ([subView isKindOfClass:[HelpView class]]) {
            HelpView *subHelpView = (HelpView *) subView;
            if ([subHelpView.uniqueIdentifier isEqual:helpView.uniqueIdentifier]) {
                alreadyAdded = YES;
            }
        }
    }
    
    if (!alreadyAdded) {
        [view addSubview:helpView];
    }
    [view bringSubviewToFront:helpView];
}

+ (void)replaceHelpViewInView:(NSString *)replaceHelpViewId withView:(HelpView *)helpView toView:(UIView *)view {
    
    BOOL alreadyAdded = NO;
    for (UIView *subView in [view subviews]) {
        if ([subView isKindOfClass:[HelpView class]]) {
            HelpView *subHelpView = (HelpView *) subView;
            if ([subHelpView.uniqueIdentifier isEqual:replaceHelpViewId]) {
                [subHelpView leaveStage:YES];
            } else if ([subHelpView.uniqueIdentifier isEqual:helpView.uniqueIdentifier]) {
                alreadyAdded = YES;
            }
        }
    }
    
    if (!alreadyAdded) {
        [view addSubview:helpView];
    }
    [view bringSubviewToFront:helpView];
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)translateString:(NSString *)dbString {
    return [[NSBundle mainBundle] localizedStringForKey:dbString value:dbString table:nil];    
}

+ (UITableViewRowAnimation)commitEditingStyleRowAnimation {
    return UITableViewRowAnimationRight;
}

@end

//
//  InfoViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 27/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ReiseabrechnungAppDelegate.h"

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    SEL _action;
    id _target;
}

@property (nonatomic, retain) IBOutlet UILabel *feedBackLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UILabel *copyrightLabel;
@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIView *topView;
@property (nonatomic, retain) IBOutlet UIButton *feedbackButton;
@property (nonatomic, retain) IBOutlet UIButton *featureButton;
@property (nonatomic, retain) IBOutlet UIButton *licenseButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIButton *rateButton;
@property (nonatomic, retain) IBOutlet UIButton *purchaseButton;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIImageView *twitterLogo;

- (IBAction)cancel;
- (IBAction)requestFeature;
- (IBAction)sendFeedback;
- (IBAction)donateNow;
- (IBAction)purchaseApp;
- (void)openEmailPopup:(NSString *)subject withTitle:(NSString *)title withMailName:(NSString *)mailName;
- (void)setButtonTitle:(UIButton *)button title:(NSString *)title;
- (void)setCloseAction:(id)target action:(SEL)action;

@end

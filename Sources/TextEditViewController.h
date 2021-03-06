//
//  TextEditViewController.h
//  Reiseabrechnung
//
//  Created by Martin Maier on 22/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TextEditViewController : UITableViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, retain) UITableViewCell *textCell;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) NSString *namedImage;

- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector;
- (id)initWithText:(NSString *)text target:(id)target selector:(SEL)selector andNamedImage:(NSString *)namedImage;

- (void)setKeyBoardType:(UIKeyboardType)keyboardType;
- (void)done;

@end

//
//  GradientCell.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/07/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "GradientCell.h"

@interface GradientCell () 
- (void)initGradient;
@end

@implementation GradientCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initGradient];
    }
    return self;    
}

- (id)initWithFrame:(CGRect)frame; {
    
    if (self = [super initWithFrame:frame]) {
        [self initGradient];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super initWithCoder:decoder]) {
        [self initGradient];
    }
    return self;    
}

- (void)initGradient {
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    _gradient = [[CAGradientLayer layer] retain];
    _gradient.frame = self.bounds;
    _gradient.startPoint = CGPointMake(0, 0);
    _gradient.endPoint = CGPointMake(0, 1);
    _gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:1] CGColor], (id)[[UIColor colorWithWhite:0.85 alpha:1] CGColor], nil];
    _gradient.needsDisplayOnBoundsChange = YES;
    
    self.backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)] autorelease];
    [self.backgroundView.layer insertSublayer:_gradient atIndex:0];    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = self.backgroundView.bounds;
}

- (void)dealloc {
    [_gradient release];
    [super dealloc];
}

@end

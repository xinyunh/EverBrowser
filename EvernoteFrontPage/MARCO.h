//
//  MARCO.h
//  EvernoteFrontPage
//
//  Created by Xinyun on 6/29/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//


//Layout properties
#define DefaultMinimizedScalingFactor 0.95
#define DefaultMaximizedScalingFactor 1.00
#define DefaultNavigationBarOverlap 0.81
#define DefaultAnimationDuration 0.3
#define DefaultVerticalOrigin 100
#define DefaultNavigationControllerToolbarHeight 44
#define DefaultShadowEnabled YES
#define DefaultShadowColor [UIColor blackColor]
#define DefaultShadowOffset CGSizeMake(0, -5)
#define DefaultShadowRadius 7.0
#define DefaultShadowOpacity 0.60
#define DefaultCornerRadius 5.0

#define AddButtonWidth 100
#define MarginWidth 20

#define inputNewURL()\
UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"New URL"\
                                                message:@"Please input a new URL"\
                                               delegate:self\
                                      cancelButtonTitle:@"cancel"\
                                      otherButtonTitles:@"OK", nil];\
alert.alertViewStyle = UIAlertViewStylePlainTextInput;\
UITextField *tf = [alert textFieldAtIndex:0];\
tf.keyboardType = UIKeyboardTypeASCIICapable;\
[alert show];

#define warning() \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too many tags" \
message:@"You can only have 5 tags" \
delegate:nil   \
cancelButtonTitle:@"OK" \
otherButtonTitles:nil];  \
[alert show];
//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <MessageUI/MessageUI.h>
#import "MainViewController.h"
#import "SVModalWebViewController.h"

@interface SVWebViewController : UIViewController<CardDelegate, UIAlertViewDelegate>

- (id)initWithAddress:(NSString*)urlString withId:(NSInteger)cardID;
- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;
@property (nonatomic, strong) NSArray* rightButtons;

@end

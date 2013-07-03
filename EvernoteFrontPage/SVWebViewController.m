//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVWebViewController.h"
#import "sqlite.h"
#import "MARCO.h"

@interface SVWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic) int cardID;

@end


@implementation SVWebViewController

@synthesize availableActions;
@synthesize URL, mainWebView;

#pragma mark - Initialization
- (id)initWithAddress:(NSString *)urlString withId:(NSInteger)cardID{
    self.cardID = cardID;
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    if(self = [super init]) {
        self.URL = pageURL;
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
    }
    return self;
}

#pragma mark - Memory management
- (void)dealloc {
    mainWebView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - View lifecycle

- (void)loadView {
    self.title = @"loading";
    mainWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    self.view = mainWebView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editURL)];
    [editButton setTintColor:[UIColor colorWithRed:0 green:180.0f/255 blue:0 alpha:1]];
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveURL)];
    [saveButton setTintColor:[UIColor colorWithRed:0 green:180.0f/255 blue:0 alpha:1]];
    _rightButtons = [[NSArray alloc] initWithObjects: editButton, nil];
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:@"bar-mid.png"]
                                                  forBarMetrics: UIBarMetricsDefault];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma CardDelegate 
- (void)showNavgationItems {
    self.navigationItem.rightBarButtonItems = _rightButtons;
}

- (void)hideNavgationItems {
    self.navigationItem.rightBarButtonItems = Nil;
}

#pragma AlertDelegat
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *inputText = [[alertView textFieldAtIndex:0].text lowercaseString];
        if (inputText.length < 7 ||
            ![[inputText substringToIndex:7] isEqualToString:@"http://"]) {
            inputText = [NSString stringWithFormat:@"http://%@", inputText];
        }
        self.URL = [NSURL URLWithString:inputText];
    }
    [self loadView];
}

#pragma mark - Toolbar
- (void)editURL {
    inputNewURL();
}

- (void)saveURL {
    //Creat database
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS URL_TABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, URL TEXT)";
    [sqlite execSql:createSQL];
    
    
    //Update Data
    NSString *url_str = [self.URL absoluteString];
    NSString *updateData = [NSString stringWithFormat:
                            @"UPDATE URL_TABLE SET URL = '%@' WHERE ID = %d", url_str, self.cardID];
    [sqlite execSql:updateData];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.URL = webView.request.URL;
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self saveURL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end

//
//  MainViewController.m
//  EvernoteFrontPage
//
//  Created by Xinyun on 6/29/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "SVWebViewController.h"
#import "sqlite.h"
#import "MARCO.h"

@interface MainViewController ()
- (CGFloat) defaultVerticalOriginForIndex: (NSInteger) index;
- (CGFloat) scalingFactorForIndex: (NSInteger) index;
@property (strong, nonatomic) UIButton *addButton;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-dark-gray-tex.png"]]];
    _addButton = [[UIButton alloc] init];
    [_addButton setImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateNormal];
    [_addButton setFrame:CGRectMake(self.view.center.x - AddButtonWidth/2, DefaultVerticalOrigin - AddButtonWidth, AddButtonWidth, AddButtonWidth)];
    [_addButton addTarget:self action:@selector(showMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    
    [self reloadData];
    [_controllerCards enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:obj];
    }];
    [super viewDidLoad];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval) duration {
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _addButton.frame = CGRectMake(self.view.center.x - AddButtonWidth/2, DefaultVerticalOrigin - AddButtonWidth, AddButtonWidth, AddButtonWidth);
        [self.controllerCards enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ControllerCard *cc = obj;
            CGRect frame = cc.frame;
            CGFloat scalingFactor = [self scalingFactorForIndex:idx];
            CGFloat width = self.view.frame.size.width * scalingFactor;
            CGFloat height = (self.view.frame.size.height + MarginWidth) * scalingFactor;
            [cc setFrame:CGRectMake(self.view.center.x - width/2, frame.origin.y, width, height)];
        }];
    } else {
        _addButton.frame = CGRectMake(self.view.center.y - AddButtonWidth/2, DefaultVerticalOrigin - AddButtonWidth, AddButtonWidth, AddButtonWidth);
        [self.controllerCards enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ControllerCard *cc = obj;
            CGRect frame = cc.frame;
            CGFloat scalingFactor = [self scalingFactorForIndex:idx];
            CGFloat width = self.view.frame.size.height * scalingFactor;
            CGFloat height = (self.view.frame.size.width + MarginWidth) * scalingFactor;
            [cc setFrame:CGRectMake(self.view.center.y - width/2, frame.origin.y, width, height)];
        }];
    }
}

- (void) reloadData {
    self.viewControllerData = [sqlite inquireCardInfos];
    
    __block NSMutableArray* navigationControllers = [[NSMutableArray alloc] initWithCapacity: [self.viewControllerData count]];
    [self.viewControllerData enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController<CardDelegate>* viewController = [self noteView:self viewControllerForRow:idx];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        ControllerCard* noteContainer = [[ControllerCard alloc] initWithMainViewController:self navigationController:navigationController viewController:viewController index:idx];
        [noteContainer setDelegate: self];
        [navigationControllers addObject: noteContainer];
        [self addChildViewController: navigationController];
        [navigationController didMoveToParentViewController: self];
    }];
    
    self.controllerCards = [NSMutableArray arrayWithArray:navigationControllers];
}

- (UIViewController<CardDelegate> *)noteView:(MainViewController*)noteView viewControllerForRow:(NSInteger)row {
    NSDictionary *cardInfo = [self.viewControllerData objectAtIndex:row];
    NSInteger cardID = [[cardInfo objectForKey:@"ID"] integerValue];
    NSString *urlString = [cardInfo objectForKey:@"URL"];
    SVWebViewController* viewController = [[SVWebViewController alloc] initWithAddress:urlString withId:cardID];
    
    return viewController;
}

#pragma Drawing Methods - Used to position and present the navigation controllers on screen

- (CGFloat) defaultVerticalOriginForIndex: (NSInteger) index {
    CGFloat originOffset = index * DefaultNavigationControllerToolbarHeight * DefaultNavigationBarOverlap;
    return DefaultVerticalOrigin + originOffset;
}

- (CGFloat) scalingFactorForIndex: (NSInteger) index {
    return  powf(DefaultMinimizedScalingFactor, ([self.viewControllerData count] - index));
}

- (NSArray*) controllerCardAboveCard:(ControllerCard*) card {
    NSInteger index = [self.controllerCards indexOfObject:card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        return index > currentIndex;
    }]];
}

- (NSArray*) controllerCardBelowCard:(ControllerCard*) card {
    NSInteger index = [self.controllerCards indexOfObject: card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        return index < currentIndex;
    }]];
}

#pragma mark - Delegate implementation for ControllerCard

-(void) controllerCard:(ControllerCard*)controllerCard didChangeToDisplayState:(ControllerCardState) toState fromDisplayState:(ControllerCardState) fromState {
    if ((fromState == ControllerCardStateDefault || fromState == ControllerCardStateLifting) && toState == ControllerCardStateFullScreen) {
        [controllerCard.viewController showNavgationItems];
        [[self controllerCardAboveCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setState:ControllerCardStateHiddenTop animated:YES];
        }];
        [[self controllerCardBelowCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setState:ControllerCardStateHiddenBottom animated:YES];
        }];
    } else if (fromState == ControllerCardStateFullScreen && toState == ControllerCardStateDefault) {
        [controllerCard.viewController hideNavgationItems];
        [[self controllerCardAboveCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setState:ControllerCardStateDefault animated:YES];
        }];
        [[self controllerCardBelowCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setState:ControllerCardStateHiddenBottom animated:NO];
            [obj setState:ControllerCardStateDefault animated:YES];
        }];
    } else if (fromState == ControllerCardStateLifting && toState == ControllerCardStateDefault){
        [[self controllerCardBelowCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setState:ControllerCardStateDefault animated:YES];
        }];
    }
}

-(void) controllerCard:(ControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage {
    if (controllerCard.state == ControllerCardStateFullScreen) {
        [[self controllerCardAboveCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ControllerCard* currentCard = obj;
            CGFloat yCoordinate = (CGFloat) currentCard.origin.y * [controllerCard percentageDistanceTravelled];
            [currentCard setYCoordinate: yCoordinate];
        }];
    } else if (controllerCard.state == ControllerCardStateDefault || controllerCard.state == ControllerCardStateLifting) {
        [[self controllerCardBelowCard:controllerCard] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ControllerCard* currentCard = obj;
            CGFloat deltaDistance = controllerCard.frame.origin.y - controllerCard.origin.y;
            CGFloat yCoordinate = currentCard.origin.y + deltaDistance;
            [currentCard setYCoordinate: yCoordinate];
        }];
    }
}

- (void)deleteTheCard:(ControllerCard *)card {
    int index = [self.controllerCards indexOfObject:card];
    
    //Delete from database
    NSInteger cardID = [[[self.viewControllerData objectAtIndex:index] objectForKey:@"ID"] integerValue];
    NSString *deleteData = [NSString stringWithFormat:
                            @"DELETE FROM URL_TABLE WHERE ID = %d", cardID];
    [sqlite execSql:deleteData];
    
    //Delete from view
    [card removeFromSuperview];
    [self.viewControllerData removeObjectAtIndex:index];
    [self.controllerCards removeObject:card];
    [self.controllerCards enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ControllerCard *currentCard = obj;
        [currentCard updateIndex:idx];
    }];
}

- (void)addCardWithURL:(NSString *)URL{
    //Creat database
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS URL_TABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, URL TEXT)";
    [sqlite execSql:createSQL];
    
    
    //Insert data
    NSString *insertData = [NSString stringWithFormat:
                            @"INSERT INTO URL_TABLE (URL) VALUES ('%@')", URL];
    [sqlite execSql:insertData];
    
    //Add to data structure
    NSInteger cardID = [sqlite inquireLastCardID];
    NSDictionary *cardInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:cardID], @"ID", URL, @"URL", nil];
    [self.viewControllerData addObject:cardInfo];
    
    //Add to view
    UIViewController<CardDelegate>* viewController = [self noteView:self viewControllerForRow:self.viewControllerData.count - 1];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if ((([UIDevice currentDevice].orientation) == UIDeviceOrientationLandscapeLeft || ([UIDevice currentDevice].orientation) == UIDeviceOrientationLandscapeRight)) {
        CGRect frame = navigationController.view.frame;
        [navigationController.view setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)];
    }
    ControllerCard* noteContainer = [[ControllerCard alloc] initWithMainViewController:self navigationController:navigationController viewController:viewController index:self.viewControllerData.count - 1];
    [noteContainer setDelegate: self];
    [self.controllerCards addObject: noteContainer];
    //Add the top view controller as a child view controller
    [self addChildViewController: navigationController];
    //As child controller will call the delegate methods for UIViewController
    [navigationController didMoveToParentViewController: self];
    [self.view addSubview:noteContainer];
    [noteContainer setState:ControllerCardStateHiddenBottom animated:NO];

    [self.controllerCards enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ControllerCard *currentCard = obj;
        [currentCard updateIndex:idx];
    }];
}

- (void)showMessage {
    if (self.viewControllerData.count < 5) {
        inputNewURL();
    } else {
        warning();
    }
}

#pragma AlertDelegat
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString * newURL = [[alertView textFieldAtIndex:0].text lowercaseString];
        if (newURL.length < 7 ||
            ![[newURL substringToIndex:7] isEqualToString:@"http://"]) {
            newURL = [NSString stringWithFormat:@"http://%@", newURL];
        }
        [self addCardWithURL:newURL];
    }
}

@end




@interface ControllerCard ()
-(void) shrinkCardToScaledSize:(BOOL) animated;
-(void) expandCardToFullSize:(BOOL) animated;
@end

@implementation ControllerCard

- (id)initWithMainViewController:(MainViewController *)noteView navigationController:(UINavigationController *)navigationController viewController:(UIViewController<CardDelegate> *)viewController index:(NSInteger)index {
    _index = index;
    _originY = [noteView defaultVerticalOriginForIndex: index];
    _MainViewController = noteView;
    _navigationController = navigationController;
    _viewController = viewController;
    
    if (self = [super initWithFrame: navigationController.view.bounds]) {
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        [self addSubview: navigationController.view];
        [self.navigationController.view.layer setCornerRadius: DefaultCornerRadius];
        [self.navigationController.view setClipsToBounds:YES];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPerformPanGesture:)];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPerformTap:)];
        
        
        //Add the gestures to the navigationcontrollers navigation bar
        [self.navigationController.navigationBar addGestureRecognizer: panGesture];
        [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
        
        //Initialize the state to default
        [self setState:ControllerCardStateHiddenBottom
              animated:NO];
        [self setState:ControllerCardStateDefault animated:YES];
    }
    return self;
}

- (void)updateIndex:(NSInteger)index{
    _index = index;
    _originY = [_MainViewController defaultVerticalOriginForIndex: index];
    _scalingFactor =  [self.MainViewController scalingFactorForIndex: _index];
    [self setState:ControllerCardStateDefault animated:YES];
}

#pragma mark - UIGestureRecognizer action handlers

-(void) didPerformTap:(UITapGestureRecognizer*) recognizer {
    if (self.state == ControllerCardStateDefault) {
        [self setState:ControllerCardStateFullScreen animated:YES];
    }
}

-(void) didPerformPanGesture:(UIPanGestureRecognizer*) recognizer {
    CGPoint location = [recognizer locationInView: self.MainViewController.view];
    CGPoint translation = [recognizer translationInView: self];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.state == ControllerCardStateFullScreen) {
                [self shrinkCardToScaledSize:YES];
            } 
            self.panOriginOffset = [recognizer locationInView: self];
            break;
        
        case UIGestureRecognizerStateChanged:
            switch (self.state) {
                case ControllerCardStateDefault:
                    if (translation.y == 0 || ABS(translation.x/translation.y) > 2) {
                        self.state = ControllerCardStateRotating;
                        _curAngle = 0;
                    } else {
                        self.state = ControllerCardStateLifting;
                    }
                    break;
                
                case ControllerCardStateRotating:
                    if (translation.y == 0 || ABS(translation.x/translation.y) > 2) {
                        CGFloat angle = translation.x/200.0f;
                        if (ABS(angle) > 0.4) {
                            [self.delegate deleteTheCard:self];
                        } else {
                            if (ABS(angle - _curAngle) > 0.3) {
                                [UIView animateWithDuration:0.1 animations:^{
                                    [self setTransform:CGAffineTransformMakeRotation(angle)];
                                }];
                            } else {
                                [self setTransform:CGAffineTransformMakeRotation(angle)];
                            }
                            self.alpha = 1 - ABS(angle * 2.0f);
                            _curAngle = angle;
                        }
                    }
                    break;
                    
                default:
                    if (translation.y > 0){
                        if (self.state == ControllerCardStateFullScreen && self.frame.origin.y < _originY) {
                            if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)]) {
                                [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                            }
                        } else if (self.state == ControllerCardStateLifting && self.frame.origin.y > _originY) {
                            if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)] ) {
                                [self.delegate controllerCard:self didUpdatePanPercentage: [self percentageDistanceTravelled]];
                            }
                        }
                    }
                    [self setYCoordinate: location.y - self.panOriginOffset.y];
                    break;
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if ([self shouldReturnFromPoint:translation withCurrentState:self.state]) {
                if (self.state == ControllerCardStateFullScreen) {
                    [self setState:ControllerCardStateFullScreen animated:YES];
                } else {
                    self.alpha = 1;
                    [self setState:ControllerCardStateDefault animated:YES];
                }
            } else {
                if (self.state == ControllerCardStateFullScreen) {
                    [self setState:ControllerCardStateDefault animated:YES];
                } else {
                    [self setState:ControllerCardStateFullScreen animated:YES];
                }
            }
            break;
        
        default:
            break;
    }
}

#pragma mark - Resizing of card

-(void) shrinkCardToScaledSize:(BOOL) animated {
    if (!_scalingFactor) {
        _scalingFactor =  [self.MainViewController scalingFactorForIndex: _index];
    }
    if (animated) {
        [UIView animateWithDuration:DefaultAnimationDuration
                         animations:^{
                             [self shrinkCardToScaledSize:NO];
                         }];
    } else {
        [self setTransform: CGAffineTransformMakeScale(_scalingFactor, _scalingFactor)];
    }
}

-(void) expandCardToFullSize:(BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:DefaultAnimationDuration
                         animations:^{
                             [self expandCardToFullSize:NO];
                         }];
    } else {
        [self setTransform: CGAffineTransformMakeScale(DefaultMaximizedScalingFactor, DefaultMaximizedScalingFactor)];
    }
}

#pragma mark - Change State

- (void) setState:(ControllerCardState)state animated:(BOOL) animated{
    if (animated) {
        [UIView animateWithDuration:DefaultAnimationDuration animations:^{
            [self setState:state animated:NO];
        }];
    } else {
        switch (state) {
            case ControllerCardStateFullScreen:
                [self expandCardToFullSize: NO];
                [self setYCoordinate: 0];
                break;
            case ControllerCardStateDefault:
                [self shrinkCardToScaledSize: NO];
                [self setYCoordinate: _originY];
                break;
            case ControllerCardStateHiddenBottom:
                [self setYCoordinate: self.MainViewController.view.frame.size.height + abs(DefaultShadowOffset.height)*3];
                break;
            case ControllerCardStateHiddenTop:
                [self setYCoordinate: 0];
                break;
            default:
                break;
        }
        
        if (self.state != state) {
            ControllerCardState lastState = self.state;
            [self setState:state];
            if ([self.delegate respondsToSelector:@selector(controllerCard:didChangeToDisplayState:fromDisplayState:)]) {
                [self.delegate controllerCard:self
                      didChangeToDisplayState:state fromDisplayState: lastState];
            }
        }
    }
}

#pragma mark - Various data helpers
-(CGPoint) origin {
    return CGPointMake(0, _originY);
}

-(CGFloat) percentageDistanceTravelled {
    return self.frame.origin.y/_originY;
}

-(BOOL) shouldReturnFromPoint:(CGPoint) point withCurrentState: (ControllerCardState) state {
    switch (state) {
        case ControllerCardStateFullScreen:
            return ABS(point.y) < self.navigationController.navigationBar.frame.size.height;
        
        case ControllerCardStateLifting:
            return point.y > -self.navigationController.navigationBar.frame.size.height;
            
        case ControllerCardStateRotating:
            return TRUE;
        
        default:
            return FALSE;

    }
}

-(void) setYCoordinate:(CGFloat)yValue {
    [self setFrame:CGRectMake(self.frame.origin.x, yValue, self.frame.size.width, self.frame.size.height)];
}

-(void) setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self redrawShadow];
}

-(void) redrawShadow {
    if (DefaultShadowEnabled) {
        UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:DefaultCornerRadius];
        
        [self.layer setShadowOpacity: DefaultShadowOpacity];
        [self.layer setShadowOffset: DefaultShadowOffset];
        [self.layer setShadowRadius: DefaultShadowRadius];
        [self.layer setShadowColor: [DefaultShadowColor CGColor]];
        [self.layer setShadowPath: [path CGPath]];
    }
}

@end

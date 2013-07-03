//
//  MainViewController.h
//  EvernoteFrontPage
//
//  Created by Xinyun on 6/29/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardState.h"
@class MainViewController;
@class ControllerCard;

#pragma Protocol Definition
@protocol ControllerCardDelegate <NSObject>
@optional
//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from ControllerCardStateDefault to ControllerCardStateDefault)
-(void) controllerCard:(ControllerCard*)controllerCard didChangeToDisplayState:(ControllerCardState) toState fromDisplayState:(ControllerCardState) fromState;

//Called when user is panning and a the card has travelled X percent of the distance to the top - Used to redraw other cards during panning fanout
-(void) controllerCard:(ControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage;

-(void) deleteTheCard:(ControllerCard *)card;
@end

@protocol CardDelegate <NSObject>
@required
-(void) hideNavgationItems;
-(void) showNavgationItems;
@end

#pragma Class Definition
@interface ControllerCard : UIView {
    @private
    CGFloat _originY;
    CGFloat _scalingFactor;
    NSInteger _index;
    CGFloat _curAngle;
}
@property (nonatomic, strong) UINavigationController* navigationController;
@property (nonatomic, strong) UIViewController<CardDelegate>* viewController;
@property (nonatomic, strong) MainViewController* MainViewController;
@property (nonatomic, strong) id<ControllerCardDelegate> delegate;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGPoint panOriginOffset;
@property (nonatomic) ControllerCardState state;
-(id) initWithMainViewController: (MainViewController*) noteView navigationController:(UINavigationController*) navigationController viewController:(UIViewController<CardDelegate>*) viewController index:(NSInteger) index;
-(void) updateIndex:(NSInteger)index;
-(void) setState:(ControllerCardState) state animated:(BOOL) animated;
-(void) setYCoordinate:(CGFloat)yValue;
-(CGFloat) percentageDistanceTravelled;
@end



@interface MainViewController : UIViewController  <ControllerCardDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray* viewControllerData;
@property (nonatomic, strong) NSMutableArray* controllerCards;

@end



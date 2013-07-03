//
//  CardState.h
//  EvernoteFrontPage
//
//  Created by Xinyun on 6/29/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//

enum {
    ControllerCardStateHiddenBottom,    //Card is hidden off screen (Below bottom of visible area)
    ControllerCardStateHiddenTop,       //Card is hidden off screen (At top of visible area)
    ControllerCardStateDefault,         //Default location for the card
    ControllerCardStateFullScreen,       //Highlighted location for the card
    ControllerCardStateLifting,
    ControllerCardStateRotating
};
typedef UInt32 ControllerCardState;

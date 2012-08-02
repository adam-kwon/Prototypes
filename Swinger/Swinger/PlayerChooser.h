//
//  PlayerChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "StoreChooser.h"
#import "UserData.h"

@interface PlayerChooser : StoreChooser<CCTargetedTouchDelegate> {
    
    UserData *userData;
    
    CCArray  *availablePlayers; // array of PlayerHeadBody objects
    
    CCNode   *headPane;
    CCNode   *bodyPane;
    
    CCSprite *headTab;
    CCSprite *bodyTab;
    
    CCNode   *preview;
}

+ (id) make: (CGSize) size;

@end

//
//  StoreScene.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GPImageButton.h"
#import "UserData.h"
#import "StoreItem.h"

@interface StoreScene : CCScene<CCTargetedTouchDelegate> {
 
    CGPoint touchStart;
    CGPoint lastMoved;
    CGSize screenSize;
    
    CCArray *items;
    int     currentlyVisibleItemIndex;
    
    GPImageButton *player;
    CCNode        *playerScreen;
    GPImageButton *powerUps;
    CCNode        *powerUpScreen;
    GPImageButton *bank;
    CCNode        *bankScreen;
    GPImageButton *lives;
    CCNode        *livesScreen;
    
    CCNode        *contentArea;
    UserData      *userData;
}

+ (id) node;

@end

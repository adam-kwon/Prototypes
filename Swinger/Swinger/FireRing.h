//
//  FireRing.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/12/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "BaseCatcherObject.h"
#import "Player.h"

@interface FireRing : BaseCatcherObject {
    
    CCSprite*  ringFront;
    CCSprite*  ringBack;
    
    // physics objects
    b2Body*    bottom;
    b2Fixture* topEdge;
    b2Fixture* bottomEdge;
    
    PlayerFire* fire;
    
    // movement amount
    CGPoint movement;
    CGPoint origin;
    float   moveFactor;
    float   dtSum;
    float   frequency;
    
    float   offset;
}

- (void) burn: (Player *) player;

@property (readwrite, nonatomic, assign) float frequency;
@property (readwrite, nonatomic, assign) CGPoint movement;

@end

//
//  Building.h
//  Scroller
//
//  Created by James on 3/11/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "cocos2d.h"
#import "GameObject.h"
#import "Box2D.h"

@class Runner;

@interface Building : GameObject<PhysicsObject> 
{
    CGSize              size;
    CCSpriteBatchNode   *batch;
    BOOL                isLandingBuilding;
    BOOL                isCrumbling;
    int                 numTilesWide;
    int                 numTilesHigh;
}

- (id) initAt:(int)x_offset;
- (id) initLandingBuilding;
- (id) initBuildingWithHeight:(int)noTilesHigh;
- (void) crumble;
- (void) stopCrumble;

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) BOOL isLandingBuilding;
@property (nonatomic, readwrite, assign) BOOL isCrumbling;
@property (nonatomic, readwrite, assign) int numTilesHigh;
@end

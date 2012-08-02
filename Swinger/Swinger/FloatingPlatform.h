//
//  FloatingPlatform.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "BaseCatcherObject.h"
#import "Player.h"

@interface FloatingPlatform : BaseCatcherObject {
    
    //CGSize     screenSize;
    //BOOL       isSafeToDelete;
    CCNode    *platform;
    float      width;
    
    /*b2World *world;
    b2Body *body;
    b2Filter collideWithPlayer;
    b2Filter noCollideWithPlayer;
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;*/
}

- (void) showAt:(CGPoint)pos;
- (void) destroyPhysicsObject;
- (void) jump: (Player *) player;
- (void) run: (Player *) player at: (CGPoint) location;
- (void) reset;

+ (id) make: (float) theWidth;

@property (nonatomic, readwrite, assign) float width;

@end

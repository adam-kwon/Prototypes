//
//  Player.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "PhysicsObject.h"
#import "SpriteObject.h"

typedef enum {
    kPlayerStateNone,
    kPlayerStateGotEnergy
} PlayerState;

@interface Player : SpriteObject {
    CGSize screenSize;
    PlayerState state;
}

- (void) jump;
- (void) updateObject:(ccTime)dt withAccelX:(float)accelX;

@property (nonatomic, readwrite, assign) PlayerState state;
@end

//
//  Player.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "PhysicsObject.h"
#import "SpriteObject.h"

@interface Player : SpriteObject {
    CGSize screenSize;
}

- (void) jump;
- (void) updateObject:(ccTime)dt withAccelX:(float)accelX;
@end

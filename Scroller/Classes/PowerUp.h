//
//  PowerUp.h
//  Scroller
//
//  Created by min on 3/8/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import "PhysicsObject.h"
#import "GameObject.h"

typedef enum {
	kPowerUpStateNone,
	kPowerUpStateDestroy
} PowerUpState;

@interface PowerUp : GameObject<PhysicsObject> {
	PowerUpState state;
}

- (void) explode;

@property (nonatomic, readwrite) PowerUpState state;
@end

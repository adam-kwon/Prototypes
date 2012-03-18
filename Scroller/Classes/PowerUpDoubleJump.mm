//
//  PowerUpDoubleJump.m
//  Scroller
//
//  Created by min on 3/11/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "PowerUpDoubleJump.h"
#import "Constants.h"

@implementation PowerUpDoubleJump

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectPowerUpDoubleJump;
		state = kPowerUpStateNone;
	}
	return self;
}

- (void) dealloc {
    [super dealloc];
}
@end

//
//  PowerUpSpeedBoost.m
//  Scroller
//
//  Created by min on 3/11/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "PowerUpSpeedBoost.h"


@implementation PowerUpSpeedBoost

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectPowerUpSpeedBoost;
		state = kPowerUpStateNone;
	}
	return self;
}

- (void) dealloc {
    [super dealloc];
}

@end

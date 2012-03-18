//
//  PowerUpFlight.m
//  Scroller
//
//  Created by min on 3/22/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "PowerUpFlight.h"


@implementation PowerUpFlight

- (id)init
{
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectPowerUpFlight;
        state = kPowerUpStateNone;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

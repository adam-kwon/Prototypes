//
//  PowerUpSpeedBoostExtender.m
//  Scroller
//
//  Created by min on 3/21/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "PowerUpSpeedBoostExtender.h"

@implementation PowerUpSpeedBoostExtender

- (id)init
{
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectPowerUpSpeedBoostExtender;
        state = kPowerUpStateNone;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

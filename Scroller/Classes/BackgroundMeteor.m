//
//  MeteorSystem.m
//  Scroller
//
//  Created by min on 3/24/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "BackgroundMeteor.h"


@implementation BackgroundMeteor
@synthesize fallRate;
@synthesize minFallRate;


-(id) initWithFile:(NSString *)plistFile minFallRate:(float)rate {
    minFallRate = rate;
    fallRate = CCRANDOM_0_1() * 5.0;
    if (fallRate <= minFallRate) {
        fallRate = minFallRate;
    }
    
    [self generateSizeAndScale];
    
    self.visible = NO;
    [self stopSystem];

    
    return [super initWithFile:plistFile];
}

+(id) particleWithFile:(NSString*) plistFile minFallRate:(float)rate {
	return [[[self alloc] initWithFile:plistFile minFallRate:rate] autorelease];
}

- (void) generateSizeAndScale {
    float randSize = CCRANDOM_0_1();
    float scale = (randSize == 0 ? 0.1 : randSize * 0.5f);
    if (scale <= 0.1) {
        scale = 0.1;   
    }
    self.scale = scale;    
}

- (void)dealloc
{
    [super dealloc];
}

@end

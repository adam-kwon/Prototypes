//
//  HelloWorldLayer.m
//  SimplePendulumSimulation
//
//  Created by Min Kwon on 6/4/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {		
		// ask director the the window size
		winSize = [[CCDirector sharedDirector] winSize];
	
        swingAngle = CC_DEGREES_TO_RADIANS(90);
        gravity = 9.8;
        ropeLength = 1;
        swingScale = 150;
 
        period = 2*M_PI*sqrtf(ropeLength/gravity);
        
        
        catcher = [CCSprite spriteWithFile:@"Catcher.png"];
        catcher.position = ccp(winSize.width/2, 20);
        [self addChild:catcher];
        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)dt {
    // Equations used (http://en.wikipedia.org/wiki/Pendulum)
    // period = (2*PI) * sqrt(length/gravity)
    // theta(t) = maxTheta * cos(2*PI*t / period)
    
    float phase = swingAngle * cosf((2*M_PI*(dtSum))/period);
    float x = winSize.width/2 - swingScale * sinf(phase);
    float y = winSize.height - (swingScale * cosf(phase));
    dtSum += dt;

    catcher.position = ccp(x, y);
    catcher.rotation = CC_RADIANS_TO_DEGREES(phase);
}

- (void) draw {
    ccDrawLine(ccp(winSize.width/2, winSize.height), catcher.position);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end

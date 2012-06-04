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
	
        swingAngle = CC_DEGREES_TO_RADIANS(45);
        timeNow = tRef = CFAbsoluteTimeGetCurrent();
        swingSpeed = 1.0;
        gravity = 9.8;
        ropeLength = 3.0;
        omega = swingSpeed * sqrtf(gravity / ropeLength);
        
        catcher = [CCSprite spriteWithFile:@"Catcher.png"];
        catcher.position = ccp(winSize.width/2, 20);
        [self addChild:catcher];
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)dt {
    float phase = swingAngle * sinf(omega * (timeNow - tRef));
    float x = winSize.width/2 + 100 * sinf(phase);
    float y = 150 + 100 * -cosf(phase);
    timeNow += dt;
    
    catcher.position = ccp(x, y);
    catcher.rotation = -CC_RADIANS_TO_DEGREES(phase);
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

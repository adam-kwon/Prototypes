//
//  GameScene.m
//  ScrollerTest
//
//  Created by J S on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"


@implementation GameScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	CCLayer* layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
		// Calculate the 3 x-coords that will be used to scroll the backgrounds:  middle of
		// the visible screen, middle of the left offscreen, middle of the right offscreen
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		xCenter = screenSize.width / 2;
		xCenterLeft = screenSize.width * -1.5;
		xCenterRight = (screenSize.width * 1.5) - 5;
		yCenter = screenSize.height / 2;
		
		// The first tile of the background will initially appear in the middle of the screen
		background1 = [CCSprite spriteWithFile:@"bg1.png"];
		background1.position = CGPointMake(xCenter, yCenter);

		// The second tile of the background will initially appear offscreen
		background2 = [CCSprite spriteWithFile:@"bg1.png"];
		background2.position = CGPointMake(xCenterRight, yCenter);
		/*
		// Set up the sequences of actions to endlessly scroll the 2 background images
		CCMoveTo* bg1Move1 = [CCMoveTo actionWithDuration:3.0f position:CGPointMake(xCenterLeft, yCenter)];
		CCMoveTo* bg1Move2 = [CCMoveTo actionWithDuration:0 position:CGPointMake(xCenter, yCenter)];
		CCSequence* bg1Seq = [CCSequence actions:bg1Move1, bg1Move2, nil];
		CCRepeatForever* bg1Repeat = [CCRepeatForever actionWithAction:bg1Seq];
		
 	    CCMoveTo* bg2Move1 = [CCMoveTo actionWithDuration:3.0f position:CGPointMake(xCenter, yCenter)];
		CCMoveTo* bg2Move2 = [CCMoveTo actionWithDuration:0 position:CGPointMake(xCenterRight, yCenter)];
		CCSequence* bg2Seq = [CCSequence actions:bg2Move1, bg2Move2, nil];		
		CCRepeatForever* bg2Repeat = [CCRepeatForever actionWithAction:bg2Seq];
		
		[background1 runAction:bg1Repeat];
		[background2 runAction:bg2Repeat];
		*/
		
		[self addChild:background1];
		[self addChild:background2];
		
		
		[Player playerWithParentNode:self];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[super dealloc];
}

-(void) scheduleUpdates
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	[self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
	
	float movement=3.2f;
	float bg1X = background1.position.x;
	float bg2X = background2.position.x;
	
	if ( bg1X > xCenterLeft && bg2X > xCenter )
	{
		background1.position = CGPointMake(bg1X-movement, yCenter);
		background2.position = CGPointMake(bg2X-movement, yCenter);
	}
	else
	{
		background1.position = CGPointMake(xCenter, yCenter);
		background2.position = CGPointMake(xCenterRight, yCenter);
	}

	
	
}



@end

//
//  Player.m
//  ScrollerTest
//
//  Created by J S on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player

+(id) playerWithParentNode:(CCNode*)parentNode
{
	return [[[self alloc] initWithParentNode:parentNode] autorelease];
}


-(id) initWithParentNode:(CCNode*)parentNode
{
	if ((self = [super init]))
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];

		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"shadow-walk.plist"];
		CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode
										  batchNodeWithFile:@"shadow-walk.png"];
//		[self addChild:spriteSheet];
		[parentNode addChild:spriteSheet];

		NSMutableArray *walkAnimFrames = [NSMutableArray arrayWithCapacity:4];
		for(int i=1; i <= 4; i++)
		{
			[walkAnimFrames addObject:
				[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
				 [NSString stringWithFormat:@"shadow-run%d.png", i]]];
		}
		
		CCAnimation *walkAnim = [CCAnimation
								 animationWithFrames:walkAnimFrames delay:0.1f];
		
		playerSprite = [CCSprite spriteWithSpriteFrameName:@"shadow-run1.png"];
		playerSprite.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);

		
		CCAction *walkAction = [CCRepeatForever actionWithAction:
							   [CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
		[playerSprite runAction:walkAction];
		[spriteSheet addChild:playerSprite];
		
		// Manually add this class as receiver of targeted touch events.
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}


-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	float x = playerSprite.position.x;
	float y = playerSprite.position.y;

	// Whenever the user touches the screen, make the player jump
	CCMoveTo* jumpUp = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(x, y+12```````````````````````````````````````0)];
	CCEaseOut* easeUp = [CCEaseOut actionWithAction:jumpUp rate:4];
	CCMoveTo* jumpDown = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(x, y)];
	CCEaseIn* easeDown = [CCEaseIn actionWithAction:jumpDown rate:4];
	CCSequence* jumpSeq = [CCSequence actions:easeUp, easeDown, nil];
	
	[playerSprite runAction:jumpSeq];
	
	return YES;
}


@end

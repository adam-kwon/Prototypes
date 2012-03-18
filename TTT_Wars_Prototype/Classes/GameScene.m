//
//  HelloWorldLayer.m
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright Min Kwon 2010. All rights reserved.
//

// Import the interfaces
#import "GameScene.h"
#import "Board.h"

// HelloWorld implementation
@implementation GameLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
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
	if( (self=[super init] )) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"units.plist"];
		CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"units.png"];				

		[self addChild:spriteSheet];

		Board *board = [[Board alloc] initWithGame:self];
		[self addChild:board];
	}
	return self;
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

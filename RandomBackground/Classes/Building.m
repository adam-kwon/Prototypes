//
//  Building.m
//  RandomBackground
//
//  Created by J S on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import <stdlib.h>

@implementation Building


-(id) init
{
	int maxHeight = spriteSize*10;
	return [self initWithMaxHeight:maxHeight];
}

+(id) buildingWithMaxHeight:(int)maxHeight
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);	
	return [[[self alloc] initWithMaxHeight:maxHeight] autorelease];
}

-(id) initWithMaxHeight:(int)maxHeight
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	if ((self = [super init]))
	{
		LEFT_CORNER = @"building-yellow-0.png";
		RIGHT_CORNER = @"building-yellow-1.png";
		TOP_SIDE = @"building-yellow-2.png";
		LEFT_SIDE = @"building-yellow-4.png";
		RIGHT_SIDE = @"building-yellow-3.png";
		INSIDE = @"building-yellow-5.png";
		
		spriteSize = 32;

		// Load the building images into the cache
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"building-yellow.plist"];
		CCSpriteBatchNode *spriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"building-yellow.png"];
		[self addChild:spriteBatch];
		
		//
        // Create the building
		//
		
		// Determine how wide the building is
		int maxBlocksTall = maxHeight * spriteSize;
		int numBlocksWide = arc4random() % 10;
		int numBlocksTall = arc4random() % 6;
		
		if ( numBlocksTall > maxBlocksTall )
		{
			numBlocksTall = maxBlocksTall;
		}
		
		height = spriteSize*numBlocksTall;
		width = spriteSize*numBlocksWide;
		
		// Build from the bottom up so we can set the overall node anchor to 0,0 for simplicity
		for (int i=0; i <= numBlocksTall; i++)
		{
			float y = i * spriteSize;
			float x = 0;
			// If this is the top level use the corner blocks
			CCSprite *left;
			CCSprite *right;
			if ( i == numBlocksTall )
			{
				left = [CCSprite spriteWithSpriteFrameName:LEFT_CORNER];
				right = [CCSprite spriteWithSpriteFrameName:RIGHT_CORNER];
			}
			else
			{
				left = [CCSprite spriteWithSpriteFrameName:LEFT_SIDE];
				right = [CCSprite spriteWithSpriteFrameName:RIGHT_SIDE];				
			}

			left.anchorPoint = CGPointMake(0,0);
			left.position = CGPointMake(x-2, y-2);
			[spriteBatch addChild:left];
			
			x += spriteSize;
			// only iterate over numBlocksWide - 2 because we do the left and right edges
			// outside of this loop
			for (int j=0; j<(numBlocksWide-2); j++)
			{
				CCSprite *middle;
				if ( y == height )
				{
					middle = [CCSprite spriteWithSpriteFrameName:TOP_SIDE];
				}
				else
				{
					middle = [CCSprite spriteWithSpriteFrameName:INSIDE];
				}
				
				middle.anchorPoint = CGPointMake(0, 0);
				middle.position = CGPointMake(x-2, y-2);
				x+=spriteSize;
				[spriteBatch addChild:middle];
			}
			
			right.anchorPoint = CGPointMake(0,0);
			right.position = CGPointMake(x-2, y-2);
			[spriteBatch addChild:right];
		}
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(int) width
{
	return width;
}

-(int) height
{
	return height;
}

@end

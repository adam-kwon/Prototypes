//
//  GameScene.m
//  RandomBackground
//
//  Created by J S on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "ParallaxBackground.h"
#import "Building.h"

#import <stdlib.h>

@implementation GameScene

+(id) scene
{
	CCScene* scene = [CCScene node];
	GameScene* layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

		screenSize = [[CCDirector sharedDirector] winSize];
		
//		ParallaxBackground *background = [ParallaxBackground node];
//		[self addChild:background z:-1];
		
		Building *building = [Building node];
		building.anchorPoint = CGPointMake(0,0);
		building.position = CGPointMake(screenSize.width, 0);
		lastHeight = building.height;
		[self addChild:building z:1];
		
		buildings = [[NSMutableSet alloc] init];
		[buildings addObject:building];
		
		scrollSpeed = 2.5f;
		
		emptySpace = arc4random() % 100;
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) update:(ccTime)delta
{
	Building *building;
	float maxX = 0;

	for (Building *building in buildings)
	{
		CGPoint pos = building.position;
		
		// If this building is no longer visible, remove it from the set
		if ( (pos.x + building.width) < 0 )
		{
			[buildings removeObject:building];
			[self removeChild:building cleanup:YES];
		}
		else
		{
   		    pos.x -= scrollSpeed;			
			building.position = pos;
			float rightEdge = pos.x + building.width;
			if ( rightEdge > maxX )
			{
				maxX = rightEdge;
			}
		}
	}
	
	// Determine if a new building needs to be created and if so create one
	if ( maxX + emptySpace < screenSize.width )
	{
		// Make sure new buildings are no more than 2 blocks taller than the previous
		// building, to ensure the player is able to reach the roof
		building = [Building buildingWithMaxHeight:(lastHeight+2)];
		building.anchorPoint = CGPointMake(0,0);
		building.position = CGPointMake(screenSize.width, 0);
		lastHeight = building.height;	
		[self addChild:building z:1];

		[buildings addObject:building];
		emptySpace = (arc4random() % 80) + 20;
		
	}
}

@end

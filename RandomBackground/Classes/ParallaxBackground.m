//
//  ParallaxBackground.m
//  RandomBackground
//
//  Created by J S on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParallaxBackground.h"


@implementation ParallaxBackground
-(id) init
{
	if ((self = [super init]))
	{
		// The screensize never changes during gameplay, so we can cache it in a member variable.
		screenSize = [[CCDirector sharedDirector] winSize];
		
		numImages = 3;
		
        // Create the first set of images and position them on the screen
		CCSprite* para1 = [CCSprite spriteWithFile:@"2para1.png"];
		CCSprite* para2 = [CCSprite spriteWithFile:@"2para2.png"];
		CCSprite* para3 = [CCSprite spriteWithFile:@"2para3.png"];		
		
		para1.anchorPoint = CGPointMake(0,0);
		para2.anchorPoint = CGPointMake(0.5f,0);
		para3.anchorPoint = CGPointMake(0.5f,0);
		
		CGPoint pos1 = CGPointMake(0, 0);
		CGPoint pos2 = CGPointMake(screenSize.width/2, screenSize.height/2);

		para1.position = pos1;
		para2.position = pos2;
		para3.position = pos2;
		
        // Create the second set of images and position them one screen to the right
		CCSprite* para4 = [CCSprite spriteWithFile:@"2para1.png"];
		CCSprite* para5 = [CCSprite spriteWithFile:@"2para2.png"];
		CCSprite* para6 = [CCSprite spriteWithFile:@"2para3.png"];		
		
		para4.anchorPoint = CGPointMake(0,0);
		para5.anchorPoint = CGPointMake(0.5f,0);
		para6.anchorPoint = CGPointMake(0.5f,0);
		
		CGPoint pos3 = CGPointMake(screenSize.width, 0);
		CGPoint pos4 = CGPointMake(screenSize.width + (screenSize.width/2), screenSize.height/2);
		
		para4.position = pos3;
		para5.position = pos4;
		para6.position = pos4;		
		
		// flip the x for the 2nd batch to make the edges line up
		para4.flipX = YES;
		para5.flipX = YES;
		para6.flipX = YES;
		
		// Store all of the images in an array
		images = [[CCArray alloc] initWithCapacity:numImages];
		[images addObject:para1];
		[images addObject:para2];
		[images addObject:para3];
		[images addObject:para4];
		[images addObject:para5];
		[images addObject:para6];
		
		// Initialize the array that contains the scroll factors for individual stripes.
		speedFactors = [[CCArray alloc] initWithCapacity:numImages];
		[speedFactors addObject:[NSNumber numberWithFloat:1.2f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.5f]];
		[speedFactors addObject:[NSNumber numberWithFloat:2.5f]];

		NSAssert([speedFactors count] == numImages, @"speedFactors count does not match numStripes!");
		
		scrollSpeed = 1.0f;
		
		// Now add all images
		[self addChild:para1 z:0];
		[self addChild:para2 z:1];
		[self addChild:para3 z:2];
		[self addChild:para4 z:0];
		[self addChild:para5 z:1];
		[self addChild:para6 z:2];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[images release];
	[speedFactors release];
	[super dealloc];
}

-(void) update:(ccTime)delta
{
	CCSprite* sprite;
	CCARRAY_FOREACH(images, sprite)
	{
		NSNumber* factor = [speedFactors objectAtIndex:sprite.zOrder];
		
		CGPoint pos = sprite.position;
		pos.x -= scrollSpeed * [factor floatValue];
		
		// Reposition stripes when they're out of bounds
		if (pos.x < -screenSize.width)
		{
			pos.x += screenSize.width * 2 - 1;
		}
		
		sprite.position = pos;
	}
}


@end

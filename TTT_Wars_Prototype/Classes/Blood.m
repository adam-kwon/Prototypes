//
//  Blood.m
//  SomePuzzleGame
//
//  Created by min on 12/29/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import "Blood.h"


@implementation Blood
static BOOL animationLoaded = NO;

- (void) initAnimations {
	if (NO == animationLoaded) {
		CCLOG(@"Initialization Blood Animation");
		animationLoaded = YES;
		NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:6];
		for (int i = 1; i <= 6; i++) {
			NSString *file = [NSString stringWithFormat:@"blood_b_000%d.png", i];
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];
		}
		CCAnimation *anim = [CCAnimation animationWithFrames:animFrames];
		[[CCAnimationCache sharedAnimationCache] addAnimation:anim name:@"blood-anim"];
	}
}

- (id) init {
	if ((self = [super init])) {
		[self initAnimations];
	}
	return self;
}

- (void) splatter {
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"blood-anim"];
	[anim setDelay:0.04f];
	//	CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
	//	[self runAction:repeat];
	
	CCAction *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
	[self runAction:action];
	
}

@end

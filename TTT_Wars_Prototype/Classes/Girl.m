//
//  Girl.m
//  SomePuzzleGame
//
//  Created by min on 12/28/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import "Girl.h"
#import "Board.h"

@implementation Girl

static BOOL animationLoaded = NO;

- (void) initAnimations {
	if (NO == animationLoaded) {
		CCLOG(@"Initialization Girl Animation");
		animationLoaded = YES;
		NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:6];
		for (int i = 1; i <= 4; i++) {
			NSString *file = [NSString stringWithFormat:@"girl-%d.png", i];
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];
		}
		CCAnimation *anim = [CCAnimation animationWithFrames:animFrames];
		[[CCAnimationCache sharedAnimationCache] addAnimation:anim name:@"girl-anim"];
	}
}

- (void) removeUnit {
	CCNode *node = [self.parent getChildByTag:(self.myTag+100)];
	[node setVisible:NO];
	[node removeFromParentAndCleanup:YES];
	[self setVisible:NO];
	[self removeFromParentAndCleanup:YES];	
}

- (void) doUpdate {
	NSString *hp = [NSString stringWithFormat:@"%f", hitPoint];
	
	CCLabelTTF *lbl = (CCLabelTTF*)[self.parent getChildByTag:(self.myTag +100)];
	if (nil == lbl) {
		lbl = [CCLabelTTF labelWithString:hp fontName:@"Helvetica" fontSize:14];
		[lbl setColor:ccGREEN];
		CCLOG(@"%f %f", self.position.x, self.position.y);
		lbl.position = ccp(self.position.x, self.position.y + 30);
		[self.parent addChild:lbl z:20 tag:(self.myTag + 100)];
	} else {		
		//CCLOG(@"%f %f", self.position.x, self.position.y);
		lbl.position = ccp(self.position.x, self.position.y + 30);
		
		
		[lbl setString:[NSString stringWithFormat:@"%f", hitPoint]];
	}
	
}

- (void) attack {
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"girl-anim"];
	[anim setDelay:0.1f];
//	CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
//	[self runAction:repeat];
	
	CCAction *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
	[self runAction:action];
	CCLOG(@"girl numwins = %f", numWins);

	
	
	[super attack];

	
}

- (void) updateState {
	[super updateState];
}

- (id) init {
	if ((self = [super init])) {
		[self initAnimations];
	}
	return self;
}

@end

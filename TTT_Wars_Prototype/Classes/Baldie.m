//
//  Baldie.m
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import "Baldie.h"
#import "Board.h"

@implementation Baldie

static BOOL animationLoaded = NO;

- (void) initAnimations {
	if (NO == animationLoaded) {
		CCLOG(@"Initialization Baldie Animation");
		animationLoaded = YES;
		NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:6];
		for (int i = 1; i <= 6; i++) {
			NSString *file = [NSString stringWithFormat:@"Sword-Slash-Frame-%d.png", i];
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];
		}
		CCAnimation *anim = [CCAnimation animationWithFrames:animFrames];
		[[CCAnimationCache sharedAnimationCache] addAnimation:anim name:@"baldie-anim"];
	}
}

- (void) stopAnimating {
	[super stopAnimating];
}

- (void) removeUnit {
	CCNode *node = [self.parent getChildByTag:(self.myTag+50)];
	[node setVisible:NO];
	[node removeFromParentAndCleanup:YES];
	[self setVisible:NO];
	[self removeFromParentAndCleanup:YES];	
}
											   

- (void) doUpdate {
	NSString *hp = [NSString stringWithFormat:@"%f", hitPoint];
	
	CCLabelTTF *lbl = (CCLabelTTF*)[self.parent getChildByTag:(self.myTag+50)];
	if (nil == lbl) {
		lbl = [CCLabelTTF labelWithString:hp fontName:@"Helvetica" fontSize:14];
		[lbl setColor:ccRED];
		CCLOG(@"%f %f", self.position.x, self.position.y);
		lbl.position = ccp(self.position.x, self.position.y + 50);
		[self.parent addChild:lbl z:20 tag:(self.myTag+50)];
	} else {		//CCLOG(@"%f %f", self.position.x, self.position.y);
		
		lbl.position = ccp(self.position.x, self.position.y + 50);
		
		[lbl setString:[NSString stringWithFormat:@"%f", hitPoint]];
	}
	
}

- (void) attack {
//	CCAction *action = [CCSequence actions:
//			  [CCAnimate actionWithAnimation:raisePhaserAnim restoreOriginalFrame:YES],
//			  [CCDelayTime actionWithDuration:1.0f],
//			  [CCAnimate actionWithAnimation:shootPhaserAnim restoreOriginalFrame:NO],
//			  [CCCallFunc actionWithTarget:self selector:@selector(shootPhaser)],
//			  [CCAnimate actionWithAnimation:lowerPhaserAnim restoreOriginalFrame:NO],
//			  [CCDelayTime actionWithDuration:2.0f],
//			  nil];
	
	CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"baldie-anim"];
	[anim setDelay:0.04f];
//	CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
//	[self runAction:repeat];

	CCAction *action = [CCAnimate actionWithAnimation:anim restoreOriginalFrame:YES];
	[self runAction:action];
	CCLOG(@"baldie numwins = %f", numWins);
	
	
	[super attack];
}

- (void) updateState {
	[super updateState];
}

- (id) init {
	if ((self = [super init])) {
		[self initAnimations];
		
		
	//	numWins = 10;
	}
	return self;
}


@end

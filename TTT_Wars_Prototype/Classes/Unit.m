//
//  Unit.m
//  SomePuzzleGame
//
//  Created by min on 12/28/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import "Unit.h"
#import "Board.h"
#import "Blood.h"

@implementation Unit

@synthesize targetUnit;
@synthesize state;
@synthesize hitPoint;
@synthesize myTag;
@synthesize boardLocation;
@synthesize player;
@synthesize numWins;
@synthesize faceDirection;

- (void) incrementNumWins {
	numWins++;
}

- (void) stopAnimating {
	[self stopAllActions];
	CCLOG(@"Unit->stopAnimation should be overridden");
}

- (void) attack {
	float hp = targetUnit.hitPoint;
	float dmg = CCRANDOM_0_1() * 20.0f + (self.numWins * 2);
	hp -= dmg;
	targetUnit.hitPoint = hp;
	if (targetUnit.faceDirection == kFacingRight) {
		blood.position = ccp(10, 50);
	} else {
		blood.position = ccp(-10, 50);
	}
	[blood setVisible:YES];
	[blood splatter];
//	CCLOG(@"Hit target doing %f damage, hp is %f  %f,%f", dmg, hp, targetUnit.position.x, targetUnit.position.y);
	if (hp <= 0.0f) {
		[board resetBoardAtLocation:targetUnit.boardLocation];
		[targetUnit explode];
		[targetUnit setVisible:NO];
		[targetUnit removeUnit];
	}
}


- (void) explode {
	CCParticleSystem* system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"boom.plist"];
//	CGSize winSize = [[CCDirector sharedDirector] winSize];
	system.position = self.position;
	[self.parent addChild:system z:100 tag:100];			
}

- (void) doUpdate {
}

- (void) updateState {
	if (state == kUnitStateTakingDamage) {
		if (CCRANDOM_0_1() <= 0.5) {
			float damage = (1.0 + (targetUnit.numWins));
			hitPoint -= damage;
			CCLOG(@"takes damage %f  hitPoint=%f", damage, hitPoint);
		} else {
	//		CCLOG(@"MISS");
		}
		
		if (hitPoint <= 0.0f) {
			// Set state and stop animating
			[targetUnit setState:kUnitStateNone];
			[targetUnit incrementNumWins];
			[targetUnit stopAnimating];
			
			// I'm dead
			state = kUnitStateDead;
			
			// Hide and remove from screen
			[self setVisible:NO];
			[self removeFromParentAndCleanup:YES];
			
			
			[board resetBoardAtLocation:self.boardLocation];
			CCLOG(@"Remaining hitpoint=%f numWins=%f", [targetUnit hitPoint], [targetUnit numWins]);
		}
	}	
}

- (void) regainHealth {
	hitPoint += 10.0f;
	CCLOG(@"regainHealth hitPoint is %f", hitPoint);
	if (hitPoint >= 100.0f) {
		hitPoint = 100.0f;
	}
}

- (void) startHealing {
	[self schedule:@selector(regainHealth) interval:0.5];
}

- (void) stopHealing {
	[self unschedule:@selector(regainHealth)];
}

- (id) init {
	if ((self = [super init])) {
		srandom(time(NULL));
		blood = [[Blood alloc] init];
		[self addChild:blood z:100 tag:00];
		[blood setVisible:NO];
		faceDirection = kFacingRight;
		numWins = 0;
		hitPoint = 100.0f;
	}
	return self;
}

- (void) faceLeft {
	if (faceDirection == kFacingRight) {
		self.flipX = YES;
		faceDirection = kFacingLeft;
	}
}

- (void) faceRight {
	if (faceDirection == kFacingLeft) {
		self.flipX = YES;
		faceDirection = kFacingLeft;
	}
}

- (void) setBoard:(Board*)gameBoard {
	board = gameBoard;
}

@end

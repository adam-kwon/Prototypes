//
//  Board.m
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import "Board.h"
#import "Baldie.h"
#import "Girl.h"
#import "cocos2d.h"
#import "Unit.h"

@implementation Board

@synthesize theGame;

- (void) dealloc {
	[theGame release];
	[super dealloc];
}

- (void) displayAttack {
	NSString *winnerStr;
	if (whoseTurn == kPlayerTwoTurn) {
		winnerStr = [NSString stringWithFormat:@"Girlie's select target"];
	} else {
		winnerStr = [NSString stringWithFormat:@"Baldie's select target"];
	}
	CCLabelTTF *lbl = (CCLabelTTF*)[self getChildByTag:999];
	if (nil == lbl) {
		lbl = [CCLabelTTF labelWithString:winnerStr fontName:@"Helvetica" fontSize:16];
		[lbl setColor:ccBLACK];
		lbl.position = ccp(200, 300);
		[self addChild:lbl z:1 tag:999];
		
	} else {
		[lbl setString:winnerStr];
	}	
}

- (void) displayTurn {
	NSString *winnerStr;
	if (whoseTurn == kPlayerTwoTurn) {
		winnerStr = [NSString stringWithFormat:@"Girlie's place unit"];
	} else {
		winnerStr = [NSString stringWithFormat:@"Baldie's place unit"];
	}
	CCLabelTTF *lbl = (CCLabelTTF*)[self getChildByTag:999];
	if (nil == lbl) {
		lbl = [CCLabelTTF labelWithString:winnerStr fontName:@"Helvetica" fontSize:16];
		[lbl setColor:ccBLACK];
		lbl.position = ccp(100, 300);
		[self addChild:lbl z:1 tag:999];

	} else {
		[lbl setString:winnerStr];
	}

	
}

- (void) healOther {
	CCLOG(@"It is player %d turn. Healing other player.", whoseTurn);
	if (whoseTurn == kPlayerTwoTurn) {
		CCArray *units = [self children];
		for (Unit *unit in units) {
			if ([unit isKindOfClass:[Unit class]]) {
				if (unit.player == kPlayerOneTurn) {
					[unit startHealing];
				} else {
					[unit stopHealing];
				}
			}
		}
	} else {
		CCArray *units = [self children];
		for (Unit *unit in units) {
			if ([unit isKindOfClass:[Unit class]]) {
				if (unit.player == kPlayerTwoTurn) {
					[unit startHealing];
				} else {
					[unit stopHealing];
				}
			}
		}
	}
}


- (id) initWithGame:(GameLayer *)game {
	if ((self = [super init])) {
		boardLocation[0] = CGPointMake(193.0f, 193.0f);			
		boardLocation[1] = CGPointMake(293.0f, 175.0f);
		boardLocation[2] = CGPointMake(391.0f, 157.0f);
		boardLocation[3] = CGPointMake(147.0f, 139.0f);
		boardLocation[4] = CGPointMake(249.0f, 122.0f);
		boardLocation[5] = CGPointMake(353.0f, 104.0f);
		boardLocation[6] = CGPointMake(98.0f, 76.0f);
		boardLocation[7] = CGPointMake(197.0f, 57.0f);
		boardLocation[8] = CGPointMake(307.0f, 40.0f);
		
		whoseTurn = kPlayerOneTurn;
		turnState = kTurnStateNone;
		
		self.theGame = game;
	//	[game addChild:self];
		CGSize wins = [[CCDirector sharedDirector] winSize];		
		board = [CCSprite spriteWithFile:@"TTT-Board-1.png"];
	//	board.rotation = -15.0;
		[board setPosition:ccp(wins.width/2, wins.height/2)];
		
		[self addChild:board z:-1];
		[self displayTurn];
//		[self schedule:@selector(checkTTT:) interval:];
		[self scheduleUpdate];
	}
	return self;
}

- (void) resetBoardAtLocation:(int)index {
	gameBoard[index].player = kPlayerTurnNone;
	gameBoard[index].taken = NO;
	gameBoard[index].unitTag = -1;
}

- (void)onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	return YES;
}


- (PlayerTurn) getNextPlayerTurn {
	[self healOther];

	PlayerTurn turn = whoseTurn == kPlayerOneTurn ? kPlayerTwoTurn : kPlayerOneTurn;
	CCLOG(@"Switching turn to %d", turn);
	return turn;
}

- (void) update:(ccTime)delta {
//	if (turnState == kTurnStateAttackingTarget) {
		CCArray *units = [self children];
		for (Unit *unit in units) {
			if ([unit isKindOfClass:[Unit class]]) {
				[unit doUpdate];
			}
		}
//	}
	
}


- (void) placeUnitOnBoard:(int)boardLoc {
	
	if (gameBoard[boardLoc].taken) {
		if (gameBoard[boardLoc].player == whoseTurn) {
			CCLOG(@"Chose own target, so must now select unit to attack");
			// Picked spot already taken by me
			turnState = kTurnStatePlacedUnit;
			[self displayAttack];
			return;
		} else {
			// Picked spot where already taken by opponent. Lose turn.
			[self healOther];
			turnState = kTurnStateNone;
			whoseTurn = [self getNextPlayerTurn];
			[self displayTurn];
			return;			
		}
	}
	
	static int playerTagId = 10;
	Unit *unit;
	int deltaY;
	if (whoseTurn == kPlayerOneTurn) {
		CCLOG(@"Adding unit for player one");
		unit = [[Baldie alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Sword-Slash-Frame-1.png"]];		
		deltaY = 40;
	} else if (whoseTurn == kPlayerTwoTurn) {
		CCLOG(@"Adding unit for player two");
		unit = [[Girl alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"girl-1.png"]];
		deltaY = 20;
	}

	gameBoard[boardLoc].player = whoseTurn;
	gameBoard[boardLoc].taken = YES;
	gameBoard[boardLoc].unitTag = playerTagId;
	
	unit.board = self;
	unit.player = whoseTurn;
	unit.myTag = playerTagId;
	unit.boardLocation = boardLoc;
	
	unit.position = ccp(boardLocation[boardLoc].x, boardLocation[boardLoc].y + deltaY);
	[self addChild:unit z:1 tag:playerTagId];
	playerTagId++;

	[self displayAttack];
	PlayerTurn winner = kPlayerTurnNone;
	if ((gameBoard[0].taken && gameBoard[1].taken && gameBoard[2].taken)) {
		PlayerTurn p = gameBoard[0].player;
		if (gameBoard[1].player == p && gameBoard[2].player == p) {
			winner = p;
		}
	} else if ((gameBoard[3].taken && gameBoard[3].taken && gameBoard[5].taken)) {
		PlayerTurn p = gameBoard[3].player;
		if (gameBoard[4].player == p && gameBoard[5].player == p) {
			winner = p;
		}
	} else if ((gameBoard[6].taken && gameBoard[7].taken && gameBoard[8].taken)) {
		PlayerTurn p = gameBoard[6].player;
		if (gameBoard[7].player == p && gameBoard[8].player == p) {
			winner = p;
		}			
	} else if ((gameBoard[0].taken && gameBoard[3].taken && gameBoard[6].taken)) {
		PlayerTurn p = gameBoard[0].player;
		if (gameBoard[3].player == p && gameBoard[6].player == p) {
			winner = p;
		}			
	} else if ((gameBoard[1].taken && gameBoard[4].taken && gameBoard[7].taken)) {
		PlayerTurn p = gameBoard[1].player;
		if (gameBoard[4].player == p && gameBoard[7].player == p) {
			winner = p;
		}			
	} else if ((gameBoard[2].taken && gameBoard[5].taken && gameBoard[8].taken)) {
		PlayerTurn p = gameBoard[2].player;
		if (gameBoard[5].player == p && gameBoard[8].player == p) {
			winner = p;
		}			
	} else if ((gameBoard[0].taken && gameBoard[4].taken && gameBoard[8].taken)) {
		PlayerTurn p = gameBoard[0].player;
		if (gameBoard[4].player == p && gameBoard[8].player == p) {
			winner = p;
		}			
	} else if ((gameBoard[2].taken && gameBoard[4].taken && gameBoard[6].taken)) {
		PlayerTurn p = gameBoard[2].player;
		if (gameBoard[4].player == p && gameBoard[6].player == p) {
			winner = p;
		}			
	}
	
	if (winner != kPlayerTurnNone) {
		NSString *winnerStr;
		if (winner == kPlayerTwoTurn) {
			winnerStr = [NSString stringWithFormat:@"Girlie Wins!"];
		} else {
			winnerStr = [NSString stringWithFormat:@"Baldie Wins!"];
		}
		CCLabelTTF *lbl = [CCLabelTTF labelWithString:winnerStr fontName:@"Helvetica" fontSize:16];
		lbl.position = ccp(45, 180);
		[self addChild:lbl];
	}
}

- (void) stopHealing {
	CCArray *units = [self children];
	for (Unit *unit in units) {
		if ([unit isKindOfClass:[Unit class]]) {
				[unit stopHealing];
		}
	}	
}


- (void) doAttack {
	[self stopHealing];
	static BOOL isPlacedUnit = YES;
	static BOOL scheduled = NO;
	if (isPlacedUnit) {
		[placedUnit attack];
		isPlacedUnit = !isPlacedUnit;
	} else {
		[targetUnit attack];
		isPlacedUnit = !isPlacedUnit;
	}
	if (scheduled == NO) {
		scheduled = YES;
		[self schedule:@selector(doAttack) interval:0.3];
	}
	if (placedUnit.hitPoint <= 0.0f || targetUnit.hitPoint <= 0.0f) {
		turnState = kTurnStateNone;
//		whoseTurn = [self getNextPlayerTurn];
		scheduled = NO;
				
		if (placedUnit.hitPoint <= 0.0f) {
			[targetUnit incrementNumWins];
		} else {
			[placedUnit incrementNumWins];
		}
		

		whoseTurn = [self getNextPlayerTurn];
		[self displayTurn];
		[self healOther];


		[self unschedule:@selector(doAttack)];
	}
}

- (void) attackUnitOnBoard:(int)boardLoc {
	// Cannot attack own unit
	if (gameBoard[boardLoc].player == whoseTurn) {
		CCLOG(@"Cannot attack yourself");
		turnState = kTurnStateNone;
		whoseTurn = [self getNextPlayerTurn];
		[self displayTurn];
		return;
	}
	
	int playerTag = gameBoard[unitPlacedLocation].unitTag;
	int attackTag = gameBoard[targetToAttackLocation].unitTag;
	
	if (gameBoard[targetToAttackLocation].taken == YES) {
		placedUnit = (Unit *)[self getChildByTag:playerTag];
		targetUnit = (Unit *)[self getChildByTag:attackTag];
		[placedUnit setTargetUnit:targetUnit];
		[targetUnit setTargetUnit:placedUnit];
		
		if (placedUnit.boardLocation < targetUnit.boardLocation) {
			[placedUnit faceRight];
			[targetUnit faceLeft];
		} else {
			[placedUnit faceLeft];
			[targetUnit faceRight];
		}
		
		turnState = kTurnStateAttackingTarget;

		[self doAttack];
	} else {
		turnState = kTurnStateNone;
		whoseTurn = [self getNextPlayerTurn];
		[self displayTurn];
		CCLOG(@"Switching turn %d turnState is %d", whoseTurn, turnState);

	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	
	CGPoint location = [touch locationInView: [touch view]];	
	location = [[CCDirector sharedDirector] convertToGL: location];
	for (int i = 0; i < 9; i++) {
		float distance = ccpDistance(location, boardLocation[i]);
		if (distance < 35.0f) {
			if (turnState == kTurnStateNone) {
				CCLOG(@"Touched board location %d, placing unit", i);
				unitPlacedLocation = i;				
				turnState = kTurnStatePlacedUnit;
				[self placeUnitOnBoard:unitPlacedLocation];
			} else if (turnState == kTurnStatePlacedUnit) {
				CCLOG(@"Touched board location %d, choosing target", i);
				targetToAttackLocation = i;
				turnState = kTurnStateChoseTarget;
				[self attackUnitOnBoard:targetToAttackLocation];
			}
			break;
		}
	}
//	loc = location;
//	CC_RADIANS_TO_DEGREES();
//	CC_DEGREES_TO_RADIANS();
//	float radians = 30.0 * M_PI / 180;
//	float xx = location.x * cosf(-radians) - location.y * sinf(-radians);
//	float yy = location.x * cosf(-radians) + location.y + sinf(-radians);
//	CCLOG(@"Touched (%f, %f)" , location.x, location.y);
	
}

//- (void) draw {
//	if (turnState == kTurnStateChoseTarget) {
//		glColor4f(0,1,0,1);
//		ccDrawCircle(boardLocation[targetToAttackLocation], 35.0, 0, 10, NO);
//	}
//}

@end

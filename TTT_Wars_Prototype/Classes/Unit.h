//
//  Unit.h
//  SomePuzzleGame
//
//  Created by min on 12/28/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

typedef enum {
	kUnitStateNone,
	kUnitStateDead,
	kUnitStateTakingDamage
} UnitState;

typedef enum {
	kFacingRight,
	kFacingLeft
} FacingDirection;

@class Board;
@class Blood;

@interface Unit : CCSprite {
	PlayerTurn player;
	float hitPoint;
	Unit *targetUnit;
	int myTag;
	int boardLocation;
	UnitState state;
	Board *board;
	Blood *blood;
	float numWins;
	FacingDirection faceDirection;
}

- (void) faceRight;
- (void) faceLeft;
- (void) stopAnimating;
- (void) attack;
- (void) updateState;
- (void) setBoard:(Board*)gameBoard;
- (void) incrementNumWins;
- (void) startHealing;
- (void) stopHealing;
- (void) doUpdate;
- (void) removeUnit;
- (void) explode;

@property (nonatomic, retain) Unit *targetUnit;
@property (readwrite, assign) FacingDirection faceDirection;
@property (readwrite, assign) UnitState state;
@property (readwrite, assign) float hitPoint;
@property (readwrite, assign) int myTag;
@property (readwrite, assign) float numWins;
@property (readwrite, assign) int boardLocation;
@property (readwrite, assign) PlayerTurn player;


@end

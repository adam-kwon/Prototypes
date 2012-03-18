//
//  Board.h
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameScene.h"
#import "Constants.h"

@class Unit;

@interface Board : CCNode <CCTargetedTouchDelegate> {
//	int playerTag[19];
//	int playerTwoTag[9];

	BoardItem gameBoard[9];
	CCSprite *board;
	GameLayer *theGame;
	CGPoint boardLocation[9];
	PlayerTurn whoseTurn;
	TurnState turnState;

	int unitPlacedLocation;
	int targetToAttackLocation;
	
	// For debug
	CGPoint loc;
	
	Unit *placedUnit;
	Unit *targetUnit;
}

- (id) initWithGame:(GameLayer *)game;
- (void) resetBoardAtLocation:(int)index;
@property (nonatomic, retain) GameLayer *theGame;

@end

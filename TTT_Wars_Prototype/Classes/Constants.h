//
//  Constants.h
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright 2010 Min Kwon. All rights reserved.
//

#define kPlayerOneUnitAtLoc0 10
#define kPlayerOneUnitAtLoc1 11
#define kPlayerOneUnitAtLoc2 12
#define kPlayerOneUnitAtLoc3 13
#define kPlayerOneUnitAtLoc4 14
#define kPlayerOneUnitAtLoc5 15
#define kPlayerOneUnitAtLoc6 16
#define kPlayerOneUnitAtLoc7 17
#define kPlayerOneUnitAtLoc8 18

#define kPlayerTwoUnitAtLoc0 19
#define kPlayerTwoUnitAtLoc1 20
#define kPlayerTwoUnitAtLoc2 21
#define kPlayerTwoUnitAtLoc3 22
#define kPlayerTwoUnitAtLoc4 23
#define kPlayerTwoUnitAtLoc5 24
#define kPlayerTwoUnitAtLoc6 25
#define kPlayerTwoUnitAtLoc7 26
#define kPlayerTwoUnitAtLoc8 27


typedef enum {
	kPlayerTurnNone,
	kPlayerOneTurn,
	kPlayerTwoTurn
} PlayerTurn;

typedef enum {
	kTurnStateNone,
	kTurnStatePlacedUnit,
	kTurnStateChoseTarget,
	kTurnStateAttackingTarget
} TurnState;


struct BoardItem {
	BOOL taken;
	int unitTag;
	PlayerTurn player;
};
typedef struct BoardItem BoardItem;

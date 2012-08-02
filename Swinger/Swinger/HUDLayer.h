//
//  HUDLayer.h
//  Swinger
//
//  Created by James Sandoz on 5/29/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Wind.h"

@class Coin;
@class Star;
@class GPImageButton;

@interface HUDLayer : CCLayer {
    
    CGSize          screenSize;
    CCNode          *gripNode;
    CCProgressTimer *gripDonut;    
    
    //CCSprite        *pauseButton;

    CCNode          *windDisplay;
    CCLabelTTF      *windLabel;
    CCSprite        *windArrow;
    CCLabelBMFont   *windSpeed;
    
    //int             starScore;
    CCSprite        *starScoreIcon;
    CCLabelBMFont   *starScoreLabel;
    
    //int             coinScore;
    CCSprite        *coinScoreIcon;
    CCLabelBMFont   *coinScoreLabel;
    
    CCLabelBMFont   *scoreLabel;

    CCSprite        *tapButton;
    
    BOOL             initialCatch;
    BOOL             niceJump;
    int              numTries;
}

+ (HUDLayer*) sharedLayer;

- (void) resetGripBar;
- (void) countDownGrip:(float)interval;
- (void) displayWind: (Wind *) wind;

- (void) showLevelCompleteScreen;
- (void) showGameOverDialog;

- (void) addCoin;
- (void) addCoin: (int) amount;
- (void) addBonusCoin: (int) amount;
- (void) addStar;
- (void) addStar: (int) amount;

- (void) skippedCatchers: (int) numCathersSkipped;
- (void) cloudTouch;

- (void) collectCoin:(Coin *)coin;
- (void) collectStar:(Star *)star;

- (void) resetScores;

- (BOOL) handleTouchEvent:(CGPoint)touchPoint;

@end

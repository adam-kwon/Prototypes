//
//  HUDLayer.m
//  Swinger
//
//  Created by James Sandoz on 5/29/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "HUDLayer.h"

#import "Constants.h"
#import "Notifications.h"
#import "Wind.h"
#import "GPDialog.h"
#import "GPImageButton.h"
#import "GamePlayLayer.h"
#import "Coin.h"
#import "Star.h"
#import "BaseCatcherObject.h"
#import "AudioEngine.h"
#import "GPLabel.h"
#import "MainMenuScene.h"
#import "MainGameScene.h"
#import "CCLayerColor+extension.h"
#import "Player.h"
#import "UserData.h"
#import "AudioManager.h"

static const int navigationScreenTag = 600;
static const float screenTransitionTime = 0.5;

@interface HUDLayer(Private)
//- (void) updateGripBoxVertices;
- (void) initGripBar;
@end


@implementation HUDLayer

//@synthesize coinScore;
//@synthesize starScore;

static HUDLayer* instanceOfLayer;
static const float buttonScale = 1.f;

CGPoint origGripPos = CGPointZero;
CGPoint origWindPos = CGPointZero;

+ (HUDLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"HUDLayer instance not yet initialized!");
	return instanceOfLayer;
}


- (id) init {
    
    if ((self = [super init])) {
        instanceOfLayer = self;
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        //[self initPauseButton];
        [self initGripBar];
        [self initWindDisplay];
        [self initScoreDisplays];
        [self initTapButton];
    }
    
    return self;
}

//- (void) initPauseButton {
//    pauseButton = [CCSprite spriteWithFile:@"pause.png"];
//    pauseButton.position = CGPointMake(screenSize.width - [pauseButton boundingBox].size.width/2 - 5,
//                                       screenSize.height - [pauseButton boundingBox].size.height/2 - 5);
//    [self addChild:pauseButton];
//}

- (void) initTapButton {
    
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gameStarted:) 
                                                 name:NOTIFICATION_GAME_STARTED 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(playerCaught:) 
                                                 name:NOTIFICATION_PLAYER_CAUGHT 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(playerInAir) 
                                                 name:NOTIFICATION_PLAYER_IN_AIR 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(hideButton) 
                                                 name:NOTIFICATION_PLAYER_FALLING 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gameOver) 
                                                 name:NOTIFICATION_GAME_OVER 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(niceJump) 
                                                 name:NOTIFICATION_NICE_JUMP 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(windBlowing:) 
                                                 name:NOTIFICATION_WIND_BLOWING 
                                               object:nil];
    
    tapButton = [CCSprite spriteWithFile:@"pushButton.png"];
    tapButton.position = CGPointZero;
    tapButton.scale = buttonScale;
    tapButton.visible = NO;
    [self addChild:tapButton];
    
    CCLabelBMFont *tapText = [CCLabelBMFont labelWithString:@"TAP" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    tapText.position = ccp(ssipadauto(47), ssipadauto(46));
    
    CCFadeOut * fadeOut = [CCFadeOut actionWithDuration:0.1];
    CCFadeIn * fadeIn = [CCFadeIn actionWithDuration:0.1];
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.1];
    
    [tapText runAction: [CCRepeatForever actionWithAction:[CCSequence actions: fadeOut, wait, fadeIn, nil]]];
    [tapButton addChild: tapText];
}

- (void) gameStarted:(NSNotification *)notification {
    
    // reset the score counters
    [self resetScores];
    
    // notification should contain the initial catcher
    [self playerCaught: notification];
}

- (void) niceJump {
    niceJump = YES;
}

- (void) playerInAir {
    [self hideButton];
    
    //[gripNode stopAllActions];
    //gripNode.position = origGripPos;
}

- (void) gameOver {
    [self hideButton];
    
    [gripNode stopAllActions];
    gripNode.position = origGripPos;
}

- (void) playerCaught:(NSNotification *)notification {    
    
    int score = 50;
    BaseCatcherObject * catcher = (BaseCatcherObject *) notification.object;
    
    if([catcher gameObjectType] == kGameObjectWheel) {
        
        score = 100; // harder object
        tapButton.scale = 0.1f*buttonScale;
        tapButton.position = ccp(ssipadauto(65), ssipadauto(50));
        tapButton.visible = YES;
        
        // Animate button to plop onto the screen
        CCScaleTo * scale1 = [CCScaleTo actionWithDuration:0.2 scale:1.2f*buttonScale];
        CCCallFunc * blop = [CCCallFunc actionWithTarget:self selector:@selector(playBlop)];
        CCScaleTo * scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.8f*buttonScale];
        CCScaleTo * scale3 = [CCScaleTo actionWithDuration:0.1 scale:1.1f*buttonScale];
        CCScaleTo * scale4 = [CCScaleTo actionWithDuration:0.1 scale:0.9f*buttonScale];
        CCScaleTo * scale5 = [CCScaleTo actionWithDuration:0.1 scale:1.f*buttonScale];
        CCSequence * seq = [CCSequence actions: scale1, blop, scale2, scale3, scale4, scale5, nil];
        
        [tapButton stopAllActions];
        [tapButton runAction: seq];
    } else {
        [self hideButton];
        
        if ([catcher gameObjectType] == kGameObjectCannon || 
            [catcher gameObjectType] == kGameObjectSpring ||
            [catcher gameObjectType] == kGameObjectElephant) {
            
            score = 75;
        }
    }
    
    if (!initialCatch) {
        [self addScore: score];
        
        if (niceJump) {
            // if player did a nice release and is caught then give him bonus points
            [self perfectRelease];
            niceJump = NO;
        } else if ([catcher gameObjectType] != kGameObjectSpring &&
                   [catcher gameObjectType] != kGameObjectElephant &&
                   [catcher gameObjectType] != kGameObjectFireRing) {
            [self imperfectRelease];
        }
    }
    
    initialCatch = NO;
}

- (void) hideButton {
    [tapButton stopAllActions];
    tapButton.visible = NO;
}

- (void) playBlop {
    
    [[AudioEngine sharedEngine] playEffect:SND_BLOP];
}

- (BOOL) handleTouchEvent:(CGPoint)touchPoint {
    BOOL swallowed = NO;
    if (tapButton.visible) {
        if (touchPoint.x > 0 && touchPoint.x < [tapButton contentSize].width
            && touchPoint.y > 0 && touchPoint.y < [tapButton contentSize].height) 
        {            
            swallowed = YES;

            CCScaleTo * scale1 = [CCScaleTo actionWithDuration:0.05 scale:0.8f*buttonScale];
            CCScaleTo * scale2 = [CCScaleTo actionWithDuration:0.05 scale:1.f*buttonScale];
            CCSequence * seq = [CCSequence actions: scale1, scale2, nil];
            
            [tapButton stopAllActions];
            [tapButton runAction: seq];
            
            Player *player = [[GamePlayLayer sharedLayer] getPlayer];
            [player handleTapEvent];
        }
    }
    
    return swallowed;
}


- (void) resetGripBar {
    
    if (gripDonut.percentage <= 95) {
        [self addScore: 25]; // jumped in the nick of time, bonus points
    }
    
    [gripDonut stopAllActions];
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(gripRunningOut) forTarget:self];
    gripDonut.percentage = 0.f;
    
    [gripNode stopAllActions];
    gripNode.position = origGripPos;
}


- (void) gripRanOut {
    [[[GamePlayLayer sharedLayer] getPlayer] gripRanOut];
}

- (void) countDownGrip:(float)interval {
    CCProgressTo *to = [CCProgressTo actionWithDuration:interval percent:100];
    id finishCallback = [CCCallFunc actionWithTarget:self selector:@selector(gripRanOut)];
    id seq = [CCSequence actions:to, finishCallback, nil];
    [gripDonut runAction:seq];

    // grip running out
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(gripRunningOut) forTarget:self interval:interval-10 paused:NO];
}

- (void) gripRunningOut {
    
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(gripRunningOut) forTarget:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIME_RUNNING_OUT object:nil];
    
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.25f];
    
    float duration = 0.25f;
    float xMove = ssipadauto(5);
    float yMove = ssipadauto(5);
    
    // Animate timer to warn player
    CCCallFunc * heartBeat = [CCCallFunc actionWithTarget:self selector:@selector(doHeartBeat)];
    CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(-xMove, -yMove)];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:duration scale:1.1f];
    CCSpawn *spawn = [CCSpawn actions:move, scale, nil];
    CCMoveBy *moveBack = [CCMoveBy actionWithDuration:duration position:ccp(xMove,yMove)];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:duration scale:1.f];
    CCSpawn *spawn2 = [CCSpawn actions:moveBack, scaleBack, nil];
    
    [gripNode stopAllActions];
    [gripNode runAction: heartBeat];
    [gripNode runAction: [CCRepeat actionWithAction: [CCSequence actions: spawn, spawn2, wait, wait, nil] times: 10]];
}

- (void) doHeartBeat {
    [[AudioManager sharedManager] playHeartBeat];
}

- (void) windBlowing: (NSNotification *) notification {
    Wind * wind = nil;
    
    if (notification.object != nil) {
        wind = (Wind *) notification.object;
    }
    
    [self displayWind: wind];
}

- (void) displayWind: (Wind*) wind {
    
    [windDisplay stopAllActions];
    
    // reposition wind display - in case we are stopping in the middle of the animation
    windDisplay.position = origWindPos;
    
    NSString * description = nil;
    
    if(wind != nil) {
        Direction direction = wind.direction;
        
        if(direction == kDirectionN) {
            windArrow.rotation = 0;
        } else if(direction == kDirectionS) {
            windArrow.rotation = 180;
        } else if(direction == kDirectionE) {
            windArrow.rotation = 90;
        } else if(direction == kDirectionW) {
            windArrow.rotation = -90;
        } else if(direction == kDirectionNE) {
            windArrow.rotation = 45;
        } else if(direction == kDirectionNW) {
            windArrow.rotation = -45;
        } else if(direction == kDirectionSE) {
            windArrow.rotation = 135;
        } else if(direction == kDirectionSW) {
            windArrow.rotation = -135;
        }
        
        description = [NSString stringWithFormat:@"%.0f mph", wind.speed ];
    }
    
    if(description != nil) {
        windLabel.visible = YES;
        [windSpeed setString:description];
        
        CCDelayTime * wait = [CCDelayTime actionWithDuration:0.5f];
        
        float duration = 0.5f;
        float xMove = ssipadauto(-25);//-screenSize.width/2);
        float yMove = ssipadauto(-25);//-screenSize.height/2);
        
        
        CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(xMove,yMove)];
        CCScaleTo *scale = [CCScaleTo actionWithDuration:duration scale:2.f];
        CCSpawn *spawn = [CCSpawn actions:move, scale, nil];
        CCMoveBy *moveBack = [CCMoveBy actionWithDuration:duration position:ccp(-xMove,-yMove)];
        CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:duration scale:1.f];
        CCSpawn *spawn2 = [CCSpawn actions:moveBack, scaleBack, nil];
        
        windDisplay.visible = YES;
        [self windArrowAnimation: wind.speed];
        [windDisplay runAction: [CCSequence actions:spawn, wait, spawn2, nil]];
    } else {
        windDisplay.visible = NO;
        [windArrow stopAllActions];
        [windDisplay stopAllActions];
    }
}

- (void) windArrowAnimation: (float) speed {
    
    id action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"windArrowAnimation"] restoreOriginalFrame:NO];
    id arrowAnim = [CCRepeatForever actionWithAction:action];
    id arrowSpeedAction = [CCSpeed actionWithAction:arrowAnim speed:speed*0.2];
    
    [windArrow stopAllActions];
    [windArrow runAction:arrowSpeedAction];
}

- (void) initWindDisplay {
    
    windDisplay = [CCNode node];
    
    CGPoint anchorPoint = ccp(0,0.5);
    float yPos = gripNode.position.y + ssipadauto(4);
    float xPos = gripNode.position.x - ([gripDonut boundingBox].size.width) - 20;
    
    windArrow = [CCSprite spriteWithSpriteFrameName:@"Wind_1.png"];
    windArrow.position = CGPointZero;
    windArrow.opacity = 150;
    [windDisplay addChild: windArrow];
    
    windLabel = [CCLabelBMFont labelWithString:@"WIND" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    windLabel.anchorPoint = anchorPoint;
    windLabel.position = ccp(0, ssipadauto(10));
    windLabel.scale = 0.25f;
    [windDisplay addChild: windLabel];
    
    windSpeed  = [CCLabelBMFont labelWithString:@"" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    windSpeed.anchorPoint = ccp(0.5, 0.5);//anchorPoint;
    windSpeed.position = CGPointZero;
    windSpeed.scale = 0.5f;
    [windDisplay addChild: windSpeed];
    
    windDisplay.position = ccp(xPos, yPos);
    origWindPos = windDisplay.position;
    [self addChild: windDisplay z:1];
}

- (void) initScoreDisplays {
    numTries = 0;
    
    coinScoreIcon = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
    coinScoreIcon.position = ssipad(ccp(260,725), ccp(135,300));
    [self addChild:coinScoreIcon];
    
    CCLabelBMFont * coinScoreXLabel = [CCLabelBMFont labelWithString:@"x" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    coinScoreXLabel.scale = 0.5f;
    coinScoreXLabel.position = ssipad(ccp(66,22), ccp(33,11));
    coinScoreXLabel.color = FONT_COLOR_YELLOW;
    [coinScoreIcon addChild:coinScoreXLabel];
    
    coinScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    coinScoreLabel.anchorPoint = ccp(0,0);
    coinScoreLabel.position = ssipad(ccp(74,-4), ccp(37,-2));
    coinScoreLabel.color = FONT_COLOR_YELLOW;
    [coinScoreIcon addChild:coinScoreLabel];

    starScoreIcon = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
    starScoreIcon.position = ssipad(ccp(45,725),ccp(20,300));
    [self addChild:starScoreIcon];
    
    CCLabelBMFont * starXLabel = [CCLabelBMFont labelWithString:@"x" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    starXLabel.scale = 0.5f;
    starXLabel.position = ssipad(ccp(77,24), ccp(41,12));
    [starScoreIcon addChild:starXLabel];
    
    starScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    starScoreLabel.anchorPoint = ccp(0,0);
    starScoreLabel.position = ssipad(ccp(85,0), ccp(45,0));
    //starScoreLabel.color = FONT_COLOR_RED;
    [starScoreIcon addChild:starScoreLabel];
    
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    scoreLabel.anchorPoint = ccp(0,1);
    scoreLabel.position = ssipad(ccp(635, 760), ccp(300, 318));
    [self addChild: scoreLabel];
    initialCatch = YES;
}

- (void) resetScores {
    [UserData sharedInstance].currentCoins = 0;
    [UserData sharedInstance].currentStars = 0;
    [UserData sharedInstance].currentScore = 0;
    [UserData sharedInstance].currentTime = 0;
    [UserData sharedInstance].landingBonus = 0;
    [UserData sharedInstance].perfectJumpCount = 0;
    [UserData sharedInstance].imperfectJumpCount = 0;
    [UserData sharedInstance].skipCount = 0;
    
    if (numTries == 0) {
        [UserData sharedInstance].restartCount = 0;
    }
    
    [coinScoreLabel setString:@"0"];
    [starScoreLabel setString:@"0"];
    [scoreLabel setString:@"0"];
    
    initialCatch = YES;
}


- (void) collectCoin:(Coin *)coin {
    
    // save the coin position
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    CGPoint currPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, coin.position.x, [GamePlayLayer sharedLayer].scale), normalizeToScreenCoord(gamePlayPosition.y, coin.position.y, [GamePlayLayer sharedLayer].scale));
    
    CCLOG(@"\n\n\n***    collectCoin: coin pos=(%f,%f), normalizedPos=(%f,%f), gameNode scale=%f, coin scale=%f, HUDLayer scale=%f    ***\n\n\n", coin.position.x, coin.position.y, currPos.x, currPos.y, [GamePlayLayer sharedLayer].scale, coin.scale, self.scale);
    
    // Move the coin from gameNode to HUDLayer.  This will allow us to move the coin to
    // the score without having to account for gameNode panning/scrolling/etc
    [[GamePlayLayer sharedLayer] collect:coin];
    [self addChild:coin];
    coin.position = currPos;
    
    // Set the scale of the coin if it's not 1 and then scale to 1 slightly faster than the move
    if ([GamePlayLayer sharedLayer].scale != 1) {
        coin.scale = [GamePlayLayer sharedLayer].scale;
        id scaleTo = [CCScaleTo actionWithDuration:.2f scale:1];
        [coin runAction:scaleTo];
    }
    
    // Now move the coin
    id move = [CCMoveTo actionWithDuration:0.25f position:coinScoreIcon.position];
    id destroy = [CCCallFunc actionWithTarget:coin selector:@selector(explode)];
    id seq = [CCSequence actions:move, destroy, nil];
    [coin runAction:seq];
}

- (void) collectStar:(Star *)star {
    
    // save the star position
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    CGPoint currPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, star.position.x, [GamePlayLayer sharedLayer].scale), normalizeToScreenCoord(gamePlayPosition.y, star.position.y, [GamePlayLayer sharedLayer].scale));
    
    // Move the star from gameNode to HUDLayer.  This will allow us to move the star to
    // the score without having to account for gameNode panning/scrolling/etc
    [[GamePlayLayer sharedLayer] collect:star];
    star.position = currPos;
    [self addChild:star];

    // Set the scale of the star if it's not 1 and then scale to 1 slightly faster than the move
    if ([GamePlayLayer sharedLayer].scale != 1) {
        star.scale = [GamePlayLayer sharedLayer].scale;
        id scaleTo = [CCScaleTo actionWithDuration:.2f scale:1];
        [star runAction:scaleTo];
    }
    
    // Now move the star
    id move = [CCMoveTo actionWithDuration:0.25f position:starScoreIcon.position];
    id destroy = [CCCallFunc actionWithTarget:star selector:@selector(explode)];
    id seq = [CCSequence actions:move, destroy, nil];
    [star runAction:seq];
}

- (void) addScore: (int) amount {
    [UserData sharedInstance].currentScore += amount;
    [scoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].currentScore]];
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:1.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:1.0];
    id seq = [CCSequence actions:bigger, normal, nil];
    [scoreLabel runAction:seq];
}

- (void) addCoin {
    [self addCoin: 1];
}

- (void) addCoin: (int) numCoins{
    [UserData sharedInstance].currentCoins += numCoins;
    [coinScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].currentCoins]];
    [UserData sharedInstance].totalCoins += numCoins;
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:1.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:1.0];
    id seq = [CCSequence actions:bigger, normal, nil];
    [coinScoreLabel runAction:seq];
    
    [self addScore: 50*numCoins];
}

- (void) addBonusCoin: (int) numBonusCoins {
    [UserData sharedInstance].landingBonus += numBonusCoins;
    [self addCoin: numBonusCoins];
    [self addScore: (200*numBonusCoins) +  + (10*[[MainGameScene sharedScene] level])];
}

- (void) addStar {
    [self addStar: 1];
}

- (void) addStar: (int) numStars {
    
    [UserData sharedInstance].currentStars += numStars;
    [starScoreLabel setString:[NSString stringWithFormat:@"%d", [UserData sharedInstance].currentStars]];
    [UserData sharedInstance].totalStars += numStars;
    
    id bigger = [CCScaleTo actionWithDuration:0.07 scale:1.2];
    id normal = [CCScaleTo actionWithDuration:0.07 scale:1.0];
    id seq = [CCSequence actions:bigger, normal, nil];
    [starScoreLabel runAction:seq];
    
    [self addScore:100*numStars];
}

- (void) skippedCatchers: (int) numCatchersSkipped {
    
    [UserData sharedInstance].skipCount += numCatchersSkipped;
    [self addScore: (500*numCatchersSkipped) + (10*[[MainGameScene sharedScene] level])];
}

- (void) cloudTouch {
    [self addScore: 1000];
}

// Called when player is released at the perfect moment from the catcher.
- (void) perfectRelease {
    
    [UserData sharedInstance].perfectJumpCount++;
    [self addScore: 150];
}

- (void) imperfectRelease {
    
    [UserData sharedInstance].imperfectJumpCount++;
}

- (void) initGripBar {
    
    gripNode = [CCNode node];
    CCSprite *filled = [CCSprite spriteWithFile:@"filled.png"];
//    filled.position = CGPointMake(pauseButton.position.x - [filled boundingBox].size.width * 2, 
//                                  screenSize.height - [filled boundingBox].size.height/2);
    filled.position = CGPointMake(0,0);

    [gripNode addChild:filled];
    
    gripDonut = [CCProgressTimer progressWithFile:@"empty.png"];
    gripDonut.type = kCCProgressTimerTypeRadialCW;
    gripDonut.position = filled.position;
    [gripNode addChild: gripDonut];
    
    CCSprite *stopWatch = [CCSprite spriteWithSpriteFrameName:@"ClockFilled.png"];
    stopWatch.scale = 0.5f;
    float stopWatchHeight = ssipadauto(8);//[stopWatch boundingBox].size.height - [filled boundingBox].size.height;
    stopWatch.position = ccp(0,stopWatchHeight);
    [gripNode addChild: stopWatch z:-1];
    
    gripNode.position = CGPointMake(screenSize.width - [filled boundingBox].size.width/2 - 5,
                                    screenSize.height - [filled boundingBox].size.height/2 - stopWatchHeight);
    origGripPos = gripNode.position;
    
    [self addChild:gripNode];
}


#pragma - mark Game lifecycle
- (void) removePauseScreen {
    [self removeChildByTag:navigationScreenTag cleanup:YES];
}

- (void) dismissScreen:(int)tagNumber action:(id)a {
    CCLayerColor *bg = (CCLayerColor*)[self getChildByTag:tagNumber];
    
    // Randomize disappearance to add some spice
    int chance = arc4random() % 4;
    CGPoint p;
    if (chance == 0) {
        p = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        p = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        p = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        p = CGPointMake(screenSize.width, 0);                
    }
    
    id ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                         position:p]];
    id removePausescreen = [CCCallFunc actionWithTarget:self selector:@selector(removePauseScreen)];
    id seq = [CCSequence actions:ease, a, removePausescreen, nil];
    [bg runAction:seq];    
}

- (void) resumeGameHelper {
    id cb = [CCCallFuncO actionWithTarget:[GamePlayLayer sharedLayer] selector:@selector(resumeGame)];
    [self dismissScreen:navigationScreenTag action:cb];
}

- (void) gotoMainMenu {
    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 
                                                                                 scene:[MainMenuScene node]]];    

}

- (void) restart {
    
    [UserData sharedInstance].restartCount++;
    numTries++;
    
    id resume = [CCCallFunc actionWithTarget:[GamePlayLayer sharedLayer] selector:@selector(resumeGame)];
    id cb = [CCCallFuncO actionWithTarget:[GamePlayLayer sharedLayer] 
                                 selector:@selector(restartGame:) 
                                   object:[NSNumber numberWithBool:NO]];
    id delay = [CCDelayTime actionWithDuration:0.1];
    id seq = [CCSequence actions:delay, resume, cb, nil];
    [self dismissScreen:navigationScreenTag action:seq];
}

- (void) pauseGame {
    [super pauseGame];
    CCLayerColor *bg = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 100)];//ccc4(168, 213, 248, 200)];
    [self addChild:bg z:101 tag:navigationScreenTag];

    id ease;
    
    // Randomize where it comes from to add some spice
    int chance = arc4random() % 4;
    if (chance == 0) {
        bg.position = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        bg.position = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        bg.position = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        bg.position = CGPointMake(screenSize.width, 0);                
    }
    
    CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
    logo.anchorPoint = CGPointZero;
    logo.position = CGPointMake(screenSize.width/2 - [logo boundingBox].size.width/2, 
                                screenSize.height - [logo boundingBox].size.height - 10);
    [bg addChild:logo];
    
    GPImageButton *resume = [GPImageButton controlOnTarget:self andSelector:@selector(resumeGameHelper) imageFromFile:@"Button_Options.png"];
    resume.scaleX = 1.4;
    CCLabelBMFont *restartText = [CCLabelBMFont labelWithString:@"RESUME" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    restartText.scaleX = 0.8;
    [resume setText:restartText];
    resume.position = CGPointMake(screenSize.width/2, logo.position.y - [resume size].height/2 -  ssipad(50, 10));
    [bg addChild:resume];

    GPImageButton *restart = [GPImageButton controlOnTarget:self andSelector:@selector(restart) imageFromFile:@"Button_Play.png"];
    restart.scaleX = 1.4;
    CCLabelBMFont *resumeText = [CCLabelBMFont labelWithString:@"RESTART" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    resumeText.scaleX = 0.8;
    [restart setText:resumeText];
    restart.position = CGPointMake(screenSize.width/2, resume.position.y - [resume size].height - ssipad(20, 0));
    [bg addChild:restart];

    GPImageButton *mainMenu = [GPImageButton controlOnTarget:self andSelector:@selector(gotoMainMenu) imageFromFile:@"Button_Store.png"];
    mainMenu.scaleX = 1.4;
    CCLabelBMFont *mainMenuText = [CCLabelBMFont labelWithString:@"MAIN MENU" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    mainMenuText.scaleX = 0.8;
    [mainMenu setText:mainMenuText];
    mainMenu.position = CGPointMake(screenSize.width/2, restart.position.y - [restart size].height - ssipad(20, 0));
    [bg addChild:mainMenu];

    
    ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                      position:CGPointMake(0, 0)]];
    [bg runAction:ease];
}


- (void) showLevelCompleteScreen {
    
    numTries = 0;
    [[MainGameScene sharedScene] levelComplete:[UserData sharedInstance]];
}

- (void) showGameOverDialogHelper {
    [super pauseGame];
    CCLayerColor *bg = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 100)]; //ccc4(168, 213, 248, 200)];
    [self addChild:bg z:101 tag:navigationScreenTag];
    
    id ease;
    
    // Randomize where it comes from to add some spice
    int chance = arc4random() % 4;
    if (chance == 0) {
        bg.position = CGPointMake(0, -screenSize.height);        
    }
    else if (chance == 1) {
        bg.position = CGPointMake(0, screenSize.height);        
    }
    else if (chance == 2) {
        bg.position = CGPointMake(-screenSize.width, 0);        
    }
    else if (chance == 3) {
        bg.position = CGPointMake(screenSize.width, 0);                
    }
    
    CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
    logo.anchorPoint = CGPointZero;
    logo.position = CGPointMake(screenSize.width/2 - [logo boundingBox].size.width/2, 
                                screenSize.height - [logo boundingBox].size.height - 10);
    [bg addChild:logo];
    
    CCLabelBMFont *gameOverText = [CCLabelBMFont labelWithString:@"YOU SUCK! BOO HOO!" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    gameOverText.position = CGPointMake(screenSize.width/2, logo.position.y - [gameOverText boundingBox].size.height/2 - ssipad(30, 10));
    gameOverText.color = FONT_COLOR_YELLOW;
    [bg addChild:gameOverText];
    
    GPImageButton *restart = [GPImageButton controlOnTarget:self andSelector:@selector(restart) imageFromFile:@"Button_Play.png"];
    restart.scaleX = 1.4;
    CCLabelBMFont *restartText = [CCLabelBMFont labelWithString:@"RESTART" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    restartText.scaleX = 0.8;
    [restart setText:restartText];
    restart.position = CGPointMake(screenSize.width/2, gameOverText.position.y - [restart size].height - ssipad(20, 0));
    [bg addChild:restart];
    
    
    GPImageButton *mainMenu = [GPImageButton controlOnTarget:self andSelector:@selector(gotoMainMenu) imageFromFile:@"Button_Store.png"];
    mainMenu.scaleX = 1.4;
    CCLabelBMFont *mainMenuText = [CCLabelBMFont labelWithString:@"MAIN MENU" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
    mainMenuText.scaleX = 0.8;
    [mainMenu setText:mainMenuText];
    mainMenu.position = CGPointMake(screenSize.width/2, restart.position.y - [restart size].height - ssipad(20, 5));
    [bg addChild:mainMenu];
    
    
    ease = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:screenTransitionTime
                                                                      position:CGPointMake(0, 0)]];
    [bg runAction:ease];    
}

- (void) showGameOverDialog {
    id delay = [CCDelayTime actionWithDuration:2];
    id func = [CCCallFunc actionWithTarget:self selector:@selector(showGameOverDialogHelper)];
    id seq = [CCSequence actions:delay, func, nil];
    [self runAction:seq];
//    GPDialog *dialog = [GPDialog controlOnTarget:[GamePlayLayer sharedLayer]
//                                      okCallBack:@selector(restartGame:) 
//                                  cancelCallBack:nil 
//                                          okText:@"OK" 
//                                      cancelText:nil 
//                                      withObject:[NSNumber numberWithBool:NO]];
//    NSArray *texts = [NSArray arrayWithObjects:@"BOO HOO", nil];
//    dialog.title = @"YOU SUCK! TRY AGAIN!";
//    dialog.texts = texts;
//    [dialog buildScreen];
//    [self addChild:dialog];    
}

- (void) dealloc {
    CCLOG(@"----------------------------- HUDLayer dealloc");

    [self unscheduleAllSelectors];
    [self stopAllActions];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_CAUGHT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_IN_AIR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FALLING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NICE_JUMP object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WIND_BLOWING object:nil];
    
    [super dealloc];
}


@end

//
//  MainMenuScene.m
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "GPLabel.h"
#import "CCLayerColor+extension.h"
#import "WorldSelectScene.h"
#import "LevelCOmpleteScene.h"
#import "GPImageButton.h"
#import "AudioEngine.h"
#import "StoreScene.h"

@implementation MainMenuScene

- (id) init {
    self = [super init];
    if (self) {
        
        CCSprite *background = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        background.scale = 1.1f;
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background];
                
        const int gap = ssipadauto(55);
        
        CCSprite *logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
        logo.position = CGPointMake(ssipad(330, 153), ssipad(480, 218));
        [self addChild:logo];
        
        GPImageButton *play = [GPImageButton controlOnTarget:self andSelector:@selector(play) imageFromFile:@"Button_Play.png"];
        CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"PLAY" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [play setText:playText];
        play.position = CGPointMake(ssipad(820, 389), ssipad(473.5, 219.5));
        [self addChild:play];

        GPImageButton *options = [GPImageButton controlOnTarget:self andSelector:@selector(options) imageFromFile:@"Button_Options.png"];
        CCLabelBMFont *optionsText = [CCLabelBMFont labelWithString:@"OPTIONS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [options setText:optionsText];
        options.position = CGPointMake(play.position.x, play.position.y - gap);
        [self addChild:options];

        GPImageButton *store = [GPImageButton controlOnTarget:self andSelector:@selector(store) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *storeText = [CCLabelBMFont labelWithString:@"STORE" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [store setText:storeText];
        store.position = CGPointMake(options.position.x, options.position.y - gap);
        [self addChild:store];
        
        [self moveWallpaper:background];
    }
    
    return self;
}

- (void) moveWallpaper: (CCSprite *) theWallpaper {
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    float duration = 20;
    float moveAmt = [theWallpaper boundingBox].size.width - screenSize.width;
    
    theWallpaper.position = ccp(0,0);
    
    if (moveAmt > 0) {
        
        CCDelayTime * wait = [CCDelayTime actionWithDuration: 5.f];
        CCMoveBy * scrollRight = [CCMoveBy actionWithDuration:duration position: ccp(theWallpaper.position.x - moveAmt, 0)];
        CCScaleTo * scaleUp = [CCScaleBy actionWithDuration:duration scale:1.25f];
        CCSpawn * spawn1 = [CCSpawn actionOne:scrollRight two:scaleUp];
        CCSequence * seq1 = [CCSequence actions:wait, spawn1, [spawn1 reverse], nil];
        CCRepeatForever * runForever = [CCRepeatForever actionWithAction: seq1];
        
        [theWallpaper stopAllActions];
        [theWallpaper runAction: runForever];
    }
}

- (void) onEnter {
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:1.0/8.0];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    [super onEnter];
}

- (void) play {
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[LevelCompleteScene nodeWithStats:nil world:@"TEST" level:1]]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[WorldSelectScene node]]];
}

- (void) store {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene node]]];
}

- (void) options {
    [self play];
}

- (void) dealloc {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end

//
//  MainMenuScene.m
//  Scroller
//
//  Created by Yongrim Rhee on 3/14/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "Constants.h"
#import "MainGameScene.h"
#import "MainMenuScene.h"
#import "OptionsScene.h"
#import "ScoresScene.h"
#import "FadeTransition.h"
#import "SimpleAudioEngine.h"

@implementation MainMenuScene

-(id) init {
    self = [super init];
    if (self) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@MENU_MUSIC loop:YES];
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCSprite* placeholder = [CCSprite spriteWithFile:@"Teahupoo.png"];
        placeholder.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:placeholder];
        
        CCLabelBMFont* titleLabel = [CCLabelBMFont labelWithString:@"2 0 1 2" fntFile:@"courier.fnt"];
        titleLabel.position = CGPointMake(size.width / 2, size.height / 2 + 80);
        [self addChild:titleLabel];
        
        CCLabelBMFont* startLabel = [CCLabelBMFont labelWithString:@"Start Game" fntFile:@"courier.fnt"];
        CCLabelBMFont* optionsLabel = [CCLabelBMFont labelWithString:@"Options" fntFile:@"courier.fnt"];
        CCLabelBMFont* scoresLabel = [CCLabelBMFont labelWithString:@"Scores" fntFile:@"courier.fnt"];

        CCMenuItemLabel* startMenuLabel = [CCMenuItemLabel itemWithLabel:startLabel
                                                                    target:self 
                                                                  selector:@selector(startGame)];

        CCMenuItemLabel* optionsMenuLabel = [CCMenuItemLabel itemWithLabel:optionsLabel
                                                                target:self 
                                                              selector:@selector(navigateToOptions)];
        
        CCMenuItemLabel* scoresMenuLabel = [CCMenuItemLabel itemWithLabel:scoresLabel
                                                                target:self 
                                                              selector:@selector(navigateToScores)];
        
        CCMenu* menu = [CCMenu menuWithItems:startMenuLabel, optionsMenuLabel, scoresMenuLabel, nil];
        menu.position = CGPointMake(size.width / 2, size.height / 2 - 30);
        [menu alignItemsVerticallyWithPadding:10];
        [self addChild:menu];
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) startGame {
    [CCDirector fadeIntoScene:[MainGameScene node]];
}

-(void) navigateToScores {
    [CCDirector fadeIntoScene:[ScoresScene node]];
}

-(void) navigateToOptions {
    [CCDirector fadeIntoScene:[OptionsScene node]];
}

@end

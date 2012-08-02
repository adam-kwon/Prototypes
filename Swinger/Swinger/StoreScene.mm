//
//  StoreScene.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GPLabel.h"
#import "GPUtil.h"
#import "CCLayerColor+extension.h"
#import "LevelSelectScene.h"
#import "GPImageButton.h"
#import "AudioEngine.h"
#import "TextureTypes.h"
#import "StoreScene.h"
#import "UserData.h"
#import "MainMenuScene.h"
#import "StoreItem.h"
#import "PlayerChooser.h"

NSMutableArray * buttonCache;

@implementation StoreScene

+ (id) node {
    return [[[self alloc] initWithUserData:[UserData sharedInstance]] autorelease];
}

- (id) initWithUserData: (UserData *) theData {
    
    self = [super init];
    if (self) {
        
        userData = theData;
        [self loadSpriteSheets];
        screenSize = [[CCDirector sharedDirector] winSize];
        buttonCache = [[NSMutableArray alloc] initWithCapacity: 4];
        
        // Nil out screens - not sure if necessary
        playerScreen = nil;
        powerUpScreen = nil;
        livesScreen = nil;
        bankScreen = nil;
        
        // shadow
        CCLayerColor * shadow = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 40)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        CCNode * bankInfo = [CCNode node];
        bankInfo.contentSize = ssipad(CGSizeMake(240, 130), CGSizeMake(120, 65));
        bankInfo.anchorPoint = ccp(0,1);
        bankInfo.position = ccp(ssipadauto(10), screenSize.height - ssipadauto(10));
        //bankInfo.scale = 0.5;
        [self addChild: bankInfo];
        
        CCLayerColor *background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 225)];
        background.contentSize = bankInfo.contentSize;
        background.anchorPoint = bankInfo.anchorPoint;
        background.position = ccp(0,0);
        [bankInfo addChild: background z:-1];
        
        // Coins section
        CCSprite * coin1 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin1.anchorPoint = ccp(0,1);
        coin1.scale = 0.98;
        coin1.position = ccp(ssipad(10,5),ssipad(120,60));
        [bankInfo addChild: coin1];
        
        /*CCSprite * coin2 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin2.anchorPoint = ccp(0.5,0.5);
        coin2.position = ccp(coin1.position.x + ssipadauto(15), coin1.position.y - ssipadauto(5));
        [bankInfo addChild: coin2 z:-1];*/
        
        CCLabelBMFont * coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", theData.totalCoins] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        //coins.scale = 0.5;
        coins.anchorPoint = ccp(0,0.5);
        coins.position = ccp(coin1.position.x + ssipadauto(30), coin1.position.y - ssipadauto(15));
        [bankInfo addChild: coins z:1];
        
        /*CCSprite * coin3 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin3.anchorPoint = ccp(0.5,0.5);
        coin3.position = ccp(coin1.position.x, coin2.position.y - ssipadauto(5));
        [bankInfo addChild: coin3];*/
        
        GPImageButton *addBank = [GPImageButton controlOnTarget:self andSelector:@selector(goToBank) imageFromFile:@"Button_Options.png"];
        CCLabelBMFont *text = [CCLabelBMFont labelWithString:@"ADD" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        [addBank setText:text];
        addBank.anchorPoint = ccp(0,1);
        addBank.scaleX = .35f;
        addBank.scaleY = .55f;
        text.scale = 1.25;
        addBank.position = ccp(coin1.position.x + ssipadauto(25), coin1.position.y - ssipadauto(45));
        [bankInfo addChild: addBank];
        
        // main buttons
        GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"backButton.png"];
        backButton.position = CGPointMake(ssipad(890, 434), ssipad(704, 298));
        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [backButton setText:backText];
        
        [self addChild:backButton];
        
        player = [GPImageButton controlOnTarget:self andSelector:@selector(pickPlayer) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"PLAYER" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.75;
        [player setText:text];
        player.position = ccp(ssipad(150, 75), ssipad(bankInfo.position.y - 250, bankInfo.position.y - 125));
        //player.scale = 0.8;
        [self addChild:player];
        [buttonCache addObject:player];
        
        float buttonGap = ssipadauto(45);
        
        powerUps = [GPImageButton controlOnTarget:self andSelector:@selector(buyPowerups) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"POWER UPS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.75f;
        [powerUps setText:text];
        powerUps.position = ccp(player.position.x, player.position.y - buttonGap);
        //powerUps.scale = 0.8;
        [self addChild:powerUps];
        [buttonCache addObject: powerUps];
        
        lives = [GPImageButton controlOnTarget:self andSelector:@selector(buyLifeLines) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"LIFE LINES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.75f;
        [lives setText:text];
        lives.position = ccp(powerUps.position.x, powerUps.position.y - buttonGap);
        //lives.scale = 0.8;
        [self addChild:lives];
        [buttonCache addObject: lives];
        
        bank= [GPImageButton controlOnTarget:self andSelector:@selector(goToBank) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"BANK" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.75f;
        [bank setText:text];
        bank.position = ccp(lives.position.x, lives.position.y - buttonGap);
        //bank.scale = 0.8;
        [self addChild:bank];
        [buttonCache addObject: bank];
        
        // Separator
        ccColor4B lineColor = ccc3to4(CC3_COLOR_CANTALOPE, 255);
        
        CCLayerColor *separator = [CCLayerColor layerWithColor:lineColor];
        [separator setContentSize:CGSizeMake(1,ssipad(-694,-300))];
        separator.position = ccp(player.position.x + [player boundingBox].size.width + ssipad(126, 63), player.position.y + ssipad(200, 100));
        [self addChild: separator z:-1];
        
        // Content Area
        contentArea = [CCNode node];
        contentArea.anchorPoint = ccp(0,1);
        contentArea.contentSize = ssipad(CGSizeMake(730,700), CGSizeMake(333,296));
        contentArea.position = ccp(separator.position.x + ssipadauto(2), backButton.position.y);
        [self addChild: contentArea z:-1];
        
        /*background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 100)];
        background.contentSize = contentArea.contentSize;
        background.anchorPoint = contentArea.anchorPoint;
        background.position = ccp(0,0);
        [contentArea addChild: background z:-1];*/
        
        //CCSprite * wallPaper = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        CCSprite * wallPaper = [CCSprite spriteWithSpriteFrameName:@"L1a_Background.png"];
        wallPaper.scale = 1.2f;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild: wallPaper z:-2];
        
        [self pickPlayer];
    }
    
    return self;
}

- (void) buttonClicked: (GPImageButton *) button {
    
    [self scaleUp: button];
    [button setTextColor:CC3_COLOR_WHITE];
    for (GPImageButton * btn in buttonCache) {
        if (btn != button) {
            [self scaleDown: btn];
            [btn setTextColor:CC3_COLOR_CANTALOPE];
        }
    }
}

- (void) scaleDown: (GPImageButton *) btn {
    
    CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.05 scale:0.8f];
    CCEaseIn  * easeIn  = [CCEaseIn actionWithAction: scaleTo];
    
    [btn runAction: easeIn];
}

- (void) scaleUp: (GPImageButton *) btn {
    
    CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.05 scale:0.9f];
    CCEaseOut  * easeOut  = [CCEaseOut actionWithAction: scaleTo];
    
    [btn runAction: easeOut];
}

- (void) pickPlayer {
    [self buttonClicked: player];
    
    if (playerScreen == nil) {
        // lazy initialization
        [self createPlayerScreen];
    }
    
    playerScreen.visible = YES;
    
    // hide others
    if (powerUpScreen != nil)
        powerUpScreen.visible = NO;
    
    if (livesScreen != nil)
        livesScreen.visible = NO;
    
    if (bankScreen != nil)
        bankScreen.visible = NO;
}

- (void) buyPowerups {
    [self buttonClicked: powerUps];
    
    if (powerUpScreen == nil) {
        // lazy initialization
        [self createPowerUpScreen];
    }
    
    powerUpScreen.visible = YES;
    
    // hide others
    if (playerScreen != nil)
        playerScreen.visible = NO;
    
    if (livesScreen != nil)
        livesScreen.visible = NO;
    
    if (bankScreen != nil)
        bankScreen.visible = NO;
}

- (void) buyLifeLines {
    [self buttonClicked: lives];
    
    if (livesScreen == nil) {
        // lazy initialization
        [self createLivesScreen];
    }
    
    livesScreen.visible = YES;
    
    // hide others
    if (playerScreen != nil)
        playerScreen.visible = NO;
    
    if (powerUpScreen != nil)
        powerUpScreen.visible = NO;
    
    if (bankScreen != nil)
        bankScreen.visible = NO;
}

- (void) goToBank {
    [self buttonClicked: bank];
    
    if (bankScreen == nil) {
        // lazy initialization
        [self createBankScreen];
    }
    
    bankScreen.visible = YES;
    
    // hide others
    if (playerScreen != nil)
        playerScreen.visible = NO;
    
    if (powerUpScreen != nil)
        powerUpScreen.visible = NO;
    
    if (livesScreen != nil)
        livesScreen.visible = NO;
}

- (void) setHeadSkin: (id) obj {
    int index = [obj numberValue].intValue;
    
    if (index == 0) {
        // select dare devil dave
        [userData setHeadSkin:kPlayerHeadDareDevilDave];
    } else if (index == 1) {
        // select rebel dave
        [userData setHeadSkin:kPlayerHeadRebel];
    }
}

- (void) goBack {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuScene node]]];    
}

- (void) onEnter {
    CCLOG(@"**** StoreScene onEnter");
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:1.0/8.0];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    [super onEnter];
}

- (void) onExit {
    CCLOG(@"**** StoreScene onExit");
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self stopAllActions];
    [self unscheduleAllSelectors];
	[super onExit];
}

#pragma mark - Touch Handling
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    touchStart = [touch locationInView:[touch view]];
    touchStart = [[CCDirector sharedDirector] convertToGL:touchStart];
    
    lastMoved = touchStart;
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    const int threshold = 40;
    float deltaScroll = touchPoint.y - touchStart.y;
    
    if (deltaScroll < -threshold) {
        // Scroll right to left
        currentlyVisibleItemIndex = MIN([items count]-1, currentlyVisibleItemIndex+1);        
    } else if (deltaScroll > threshold) {
        // Scroll left to right
        currentlyVisibleItemIndex = MAX(0, currentlyVisibleItemIndex-1);
    } else {
        // Selection (touch)
        // Handled by respective StoreItems
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    lastMoved = touchPoint;
}

- (void) createPlayerScreen {
    playerScreen = [PlayerChooser make: ssipad(CGSizeMake(730-10,700), CGSizeMake(333-5,296))];
    [contentArea addChild: playerScreen z:1];
}

- (void) createPowerUpScreen {
    powerUpScreen = [CCNode node];
    powerUpScreen.contentSize = ssipad(CGSizeMake(730-10,140), CGSizeMake(333-5,59));
    [contentArea addChild: powerUpScreen z:1];
}

- (void) createBankScreen {
    bankScreen = [CCNode node];
    bankScreen.contentSize = ssipad(CGSizeMake(730-10,140), CGSizeMake(333-5,59));
    [contentArea addChild: bankScreen z:1];
}

- (void) createLivesScreen {
    livesScreen = [CCNode node];
    livesScreen.contentSize = ssipad(CGSizeMake(730-10,140), CGSizeMake(333-5,59));
    [contentArea addChild: livesScreen z:1];
}

- (void) loadSpriteSheets {    
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:[GPUtil getAtlasImageName:BACKGROUND_ATLAS]];        
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:BACKGROUND_ATLAS] texture:tex];
    [tex setAliasTexParameters];
}

- (void) dealloc {
    CCLOG(@"*******STORE SCENE DEALLOCATED******");
    [buttonCache removeAllObjects];
    [buttonCache release];
    
    [super dealloc];
}

@end

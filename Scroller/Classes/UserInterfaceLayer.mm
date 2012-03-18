//
//  UserInterfaceLayer.mm
//  Scroller
//
//  Created by Yongrim Rhee on 3/9/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "FadeTransition.h"
#import "UserInterfaceLayer.h"
#import "MainGameScene.h"
#import "MainMenuScene.h"

@implementation UserInterfaceLayer

-(id) init {
	if ((self = [super init])) 	{
		[self setIsTouchEnabled:NO];
	}
	
	return self;
}

-(void) dealloc {
	[super dealloc];
}

-(void) returnToMenu {
    [CCDirector fadeIntoScene:[MainMenuScene node]];
}

-(void) restartGame {
    [CCDirector fadeIntoScene:[MainGameScene node]];
}

-(void) showGameOverMenu:(int) distance {
	CGSize size = [[CCDirector sharedDirector] winSize];

    CCLabelBMFont* gameOverLabel = [CCLabelBMFont labelWithString:@"Game Over" fntFile:@"courier.fnt"];
	gameOverLabel.position = CGPointMake(size.width / 2, size.height / 2 + 30);
	[self addChild:gameOverLabel];

    CCLabelBMFont* distanceLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Distance: %d meters", distance] 
                                                          fntFile:@"courier.fnt"];
	distanceLabel.position = CGPointMake(size.width / 2, size.height / 2);
	[self addChild:distanceLabel];

    CCLabelBMFont* restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"courier.fnt"];
    CCMenuItemLabel* restartItemLabel = [CCMenuItemLabel itemWithLabel:restartLabel 
                                                                target:self 
                                                              selector:@selector(restartGame)];
    CCLabelBMFont* menuLabel = [CCLabelBMFont labelWithString:@"Main Menu" 
                                                      fntFile:@"courier.fnt"];
    CCMenuItemLabel* menuItemLabel = [CCMenuItemLabel itemWithLabel:menuLabel 
                                                             target:self 
                                                           selector:@selector(returnToMenu)];
    
	CCMenu* menu = [CCMenu menuWithItems:restartItemLabel, menuItemLabel, nil];
	menu.position = CGPointMake(size.width / 2, size.height / 2 - 30);
	[menu alignItemsHorizontallyWithPadding:40];
	[self addChild:menu];
}

@end

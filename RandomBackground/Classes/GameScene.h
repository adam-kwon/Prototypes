//
//  GameScene.h
//  RandomBackground
//
//  Created by J S on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer
{
	NSMutableSet *buildings;
	
	CGSize screenSize;
	int emptySpace;
	float lastHeight;
	float scrollSpeed;
}

+(id) scene;

@end

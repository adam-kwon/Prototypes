//
//  GameScene.h
//  ScrollerTest
//
//  Created by J S on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer
{
	CCSprite *background1;
	CCSprite *background2;
	
	float xCenter;
	float xCenterLeft;
	float xCenterRight;
	float yCenter;
}

+(id) scene;

@end

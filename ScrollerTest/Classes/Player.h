//
//  Player.h
//  ScrollerTest
//
//  Created by J S on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : NSObject <CCTargetedTouchDelegate>
{
	CCSprite* playerSprite;
}

+(id) playerWithParentNode:(CCNode*)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;

@end

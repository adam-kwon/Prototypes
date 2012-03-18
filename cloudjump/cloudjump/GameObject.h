//
//  GameObject.h
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "Constants.h"
#import "cocos2d.h"

@protocol GameObject

- (GameObjectType) gameObjectType;
- (BOOL) isSafeToDelete;
- (void) safeToDelete;
- (void) updateObject:(ccTime)dt;


@end
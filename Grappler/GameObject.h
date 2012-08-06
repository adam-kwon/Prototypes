//
//  GameObject.h
//  Grappler
//
//  Created by James Sandoz on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@protocol GameObject

- (GameObjectType) gameObjectType;
- (void) updateObject:(ccTime)dt;
- (BOOL) isSafeToDelete;
- (void) safeToDelete;

- (void) show;
- (void) hide;

- (void) moveTo:(CGPoint)pos;
- (void) showAt:(CGPoint)pos;

@end

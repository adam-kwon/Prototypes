//
//  GameObject.h
//  SwingProto
//
//  Created by James Sandoz on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@protocol GameObject

- (GameObjectType) gameObjectType;
- (void) updateObject:(ccTime)dt;

@end

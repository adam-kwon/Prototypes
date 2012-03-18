//
//  Meteor.h
//  Scroller
//
//  Created by min on 3/1/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "cocos2d.h"
#import "GameObject.h"
#import "Box2D.h"
#import "PhysicsObject.h"

typedef enum {
	kMeteorStateNone,
    kMeteorStateDestroy
} MeteorState;

@interface Meteor : GameObject<PhysicsObject> {
	MeteorState		state;
}

- (void) explode;

@property (nonatomic, readwrite) MeteorState state;

@end

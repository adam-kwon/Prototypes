//
//  Crow.h
//  Scroller
//
//  Created by min on 3/14/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "GameObject.h"
#import "Constants.h"
#import "PhysicsObject.h"

typedef enum {
    kBirdStateNone,
    kBirdSitting,
    kBirdFlying,
    kBirdDestroy
} BirdState;


@interface Crow : GameObject<PhysicsObject> {
    BirdState state;    
}

-(void) fly;

@property (nonatomic, readwrite) BirdState state;

@end

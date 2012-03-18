//
//  CCPhysicsSprite.h
//  Scroller
//
//  Created by min on 3/11/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//


#import "Box2D.h"

@interface CCPhysicsSprite : CCSprite {
	// special version of CCSprite which is used to support the fixed timestep implementation
	float _previousAngle;
	float _smoothedAngle;
	b2Vec2 _previousPosition;
	b2Vec2 _smoothedPosition;
    
}

@property (nonatomic) float32 previousAngle;
@property (nonatomic) float32 smoothedAngle;
@property (nonatomic) b2Vec2 previousPosition;
@property (nonatomic) b2Vec2 smoothedPosition;

@end
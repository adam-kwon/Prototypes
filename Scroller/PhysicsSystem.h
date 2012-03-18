//
//  PhysicsSystem.h
//  Scroller
//
//  Created by min on 3/11/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Box2D.h"
#import "CCPhysicsSprite.h"

const static float FIXED_TIME_STEP = 1.f/60.f;

class PhysicsSystem {
protected:
    float fixedTimestepAccumulator_;
    float velocityIterations_;
    float positionIterations_;
    b2World *world_;
public:
    float fixedTimestepAccumulatorRatio_;
    b2World *getWorld(void);
    void update(float dt);
    void singleStep_(float dt);
    void smoothStates_();
    void resetSmoothStates_();
    
    PhysicsSystem(void);
    ~PhysicsSystem(void);
};

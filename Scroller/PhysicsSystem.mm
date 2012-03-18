//
//  PhysicsSystem.m
//  Scroller
//
//  Created by min on 3/11/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#include "PhysicsSystem.h"

const float FIXED_TIMESTEP = 1.0f / 60.f;

PhysicsSystem::PhysicsSystem (): fixedTimestepAccumulator_ (0),velocityIterations_(8), positionIterations_(1), fixedTimestepAccumulatorRatio_(0) {
    
	//int32 velocityIterations = 8;
	//int32 positionIterations = 1;
    
	// ...
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
    
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = true;
    
	world_ = new b2World(gravity, doSleep);
    
	world_->SetAutoClearForces (false);
    
	// ...
}

b2World* PhysicsSystem::getWorld(void) {
	return world_;
}

PhysicsSystem::~PhysicsSystem (void) {
	CCLOG(@"DESTRUCTING PHYSICS...");
	delete world_;
}

void PhysicsSystem::update (float dt) {
	// Maximum number of steps, to avoid degrading to an halt.
	const int MAX_STEPS = 5;
    
	fixedTimestepAccumulator_ += dt;
	const int nSteps = static_cast<int> (
										 std::floor (fixedTimestepAccumulator_ / FIXED_TIMESTEP)
										 );
	// To avoid rounding errors, touches fixedTimestepAccumulator_ only
	// if needed.
	if (nSteps > 0)
	{
		fixedTimestepAccumulator_ -= nSteps * FIXED_TIMESTEP;
	}
    
	assert (
			"Accumulator must have a value lesser than the fixed time step" &&
			fixedTimestepAccumulator_ < FIXED_TIMESTEP + FLT_EPSILON
			);
	fixedTimestepAccumulatorRatio_ = fixedTimestepAccumulator_ / FIXED_TIMESTEP;
    
	// This is similar to clamp "dt":
	//	dt = std::min (dt, MAX_STEPS * FIXED_TIMESTEP)
	// but it allows above calculations of fixedTimestepAccumulator_ and
	// fixedTimestepAccumulatorRatio_ to remain unchanged.
	const int nStepsClamped = std::min (nSteps, MAX_STEPS);
	for (int i = 0; i < nStepsClamped; ++ i)
	{
		// In singleStep_() the CollisionManager could fire custom
		// callbacks that uses the smoothed states. So we must be sure
		// to reset them correctly before firing the callbacks.
		resetSmoothStates_ ();
		singleStep_ (FIXED_TIMESTEP);
	}
    
	world_->ClearForces ();
    
	// We "smooth" positions and orientations using
	// fixedTimestepAccumulatorRatio_ (alpha).
	smoothStates_ ();
}

void PhysicsSystem::singleStep_ (float dt) {
	// ...
    
	//updateControllers_ (dt);
	world_->Step (dt, velocityIterations_, positionIterations_);
	//consumeContacts_ ();
    
	// ...
}

void PhysicsSystem::smoothStates_ () {
	b2Vec2 newSmoothedPosition;
    
	const float oneMinusRatio = 1.f - fixedTimestepAccumulatorRatio_;
    
	for (b2Body * b = world_->GetBodyList (); b != NULL; b = b->GetNext ())
	{
		if (b->GetType () == b2_staticBody)
		{
			continue;
		}
        
		CCPhysicsSprite *c   = (CCPhysicsSprite*) b->GetUserData();
		newSmoothedPosition = fixedTimestepAccumulatorRatio_ * b->GetPosition () + oneMinusRatio * c.previousPosition;
        
		c.smoothedPosition = newSmoothedPosition;
        
		c.smoothedAngle =
		fixedTimestepAccumulatorRatio_ * b->GetAngle () +
		oneMinusRatio * c.previousAngle;
        
	}
}

void PhysicsSystem::resetSmoothStates_ ()
{
	b2Vec2 newSmoothedPosition;
    
	for (b2Body * b = world_->GetBodyList (); b != NULL; b = b->GetNext ())
	{
		if (b->GetType () == b2_staticBody)
		{
			continue;
		}
        
		CCPhysicsSprite *c   = (CCPhysicsSprite*) b->GetUserData();
        
		newSmoothedPosition = b->GetPosition ();
        
		c.smoothedPosition = newSmoothedPosition;
		c.previousPosition = newSmoothedPosition;
		c.smoothedAngle = b->GetAngle ();
		c.previousAngle = b->GetAngle();
	}
}
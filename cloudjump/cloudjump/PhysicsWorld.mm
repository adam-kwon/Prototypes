//
//  PhysicsWorld.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 6/3/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "PhysicsWorld.h"
#import "Constants.h"
#import "GameObject.h"

@implementation PhysicsWorld

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;

// Minimum remaining time to avoid box2d unstability caused by very small delta times
// if remaining time to simulate is smaller than this, the rest of time will be added to the last step,
// instead of performing one more single step with only the small delta time.
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  

const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;

// maximum number of steps per tick to avoid spiral of death
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

static PhysicsWorld* instanceOfWorld;

+ (PhysicsWorld*) sharedWorld {
	NSAssert(instanceOfWorld != nil, @"PhysicsWorld instance not yet initialized!");
	return instanceOfWorld;
}

+ (void) createInstance {
    if (!instanceOfWorld) {
        instanceOfWorld = [[PhysicsWorld alloc] init];
    }    
}

- (id) init {
    self = [super init];
    if (self) {
        instanceOfWorld = self;
        [self setupPhysicsWorld];
    }    
    return self;
}

- (void)afterStep {
	// process collisions and result from callbacks called by the step
}

- (void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
	world->ClearForces ();
}

#if DEBUG
- (void) setupDebugDraw {
	m_debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(m_debugDraw);
	uint32 flags = 0;
	flags += b2DebugDraw::e_shapeBit;
	m_debugDraw->SetFlags(flags);	
}
#endif

- (void) setupPhysicsWorld {
    b2Vec2 gravity = b2Vec2(0.0f, -30.f);
    bool doSleep = true;
    world = new b2World(gravity, doSleep);    

    // Check on this? Slows performance?
    world->SetContinuousPhysics(true);

    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    world->SetAutoClearForces(false);
    
#if DEBUG
    [self setupDebugDraw];	
#endif
}

- (void) setGravity:(float)gravity {
    world->SetGravity(b2Vec2(0.0f, gravity));    
}

- (b2World*) getWorld {
    return world;
}

- (void) destroyGround {
    [platform release];
    platform = nil;
    world->DestroyBody(groundBody); 
}

/*
- (void) makeGround:(CGSize)winSize {
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    platform = [[GameObject alloc] init];
    platform.gameObjectType = kGameObjectPlatform;
    groundBodyDef.userData = platform;
    groundBody = world->CreateBody(&groundBodyDef);
    b2PolygonShape groundBox;
    b2FixtureDef boxShapeDef;
    boxShapeDef.shape = &groundBox;
    
    groundBox.SetAsEdge(b2Vec2(0, (winSize.height-50)/PTM_RATIO/2), b2Vec2(winSize.width/PTM_RATIO, (winSize.height-50)/PTM_RATIO/2));
    groundBody->CreateFixture(&boxShapeDef);
//    
//    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
//    groundBody->CreateFixture(&boxShapeDef);
//    
//    groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), 
//                        b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
//    groundBody->CreateFixture(&boxShapeDef);
    
//    groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, 
//                               winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
//    groundBody->CreateFixture(&boxShapeDef);    
}
*/

- (void) dealloc {
    delete contactListener;
    delete world;
    contactListener = NULL;
    world = NULL;

#if DEBUG
    delete m_debugDraw;
    m_debugDraw = NULL;
#endif

    [super dealloc];
}

@end

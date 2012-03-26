//
//  HelloWorldLayer.mm
//  SwingProto
//
//  Created by James Sandoz on 3/11/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#import "Constants.h"
#import "SwingingRopeDude.h"
#import "JumpingDude.h"


// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation HelloWorldLayer


static HelloWorldLayer* instanceOfHelloWorldLayer;

#pragma mark -
#pragma mark Initialization
+(HelloWorldLayer*) sharedLayer {
	NSAssert(instanceOfHelloWorldLayer != nil, @"GamePlayLayer instance not yet initialized!");
	return instanceOfHelloWorldLayer;
}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
        
        instanceOfHelloWorldLayer = self;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
        contactListener = new ContactListener();
        world->SetContactListener(contactListener);
        world->SetAutoClearForces(false);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
        
        baseSpeed = 2;
        
//		
//        
//        SwingingRopeDude *rope1 = [[SwingingRopeDude alloc] init];
//        [rope1 createPhysicsObjectAsBox:world];
//        [ropes addObject:rope1];
//        [self addChild:rope1];
//        
//        [rope1 showAt:ccp(screenSize.width*.25, screenSize.height*.75)];
//        CCLOG(@"rope created!\n");
		

        
//        // static body to hold the swing
//        b2BodyDef holderBodyDef;
//        holderBodyDef.position.Set(screenSize.width/PTM_RATIO*.25, screenSize.height/PTM_RATIO*.75);
//        
//        holderBody = world->CreateBody(&holderBodyDef);
//        
//        b2PolygonShape holderBox;
//        holderBox.SetAsBox(.25f, .25f);
//        
//        b2Fixture *holderFixture = holderBody->CreateFixture(&holderBox,0);
//        b2Filter holderFilter;
//        holderFilter.categoryBits = CATEGORY_HOLDER;
//        holderFilter.maskBits = 0;
//        holderFixture->SetFilterData(holderFilter);
//        
//        // create a 2nd
//        b2BodyDef holderBodyDef2;
//        holderBodyDef2.position.Set(screenSize.width/PTM_RATIO*.75, screenSize.height/PTM_RATIO*.75);
//        
//        b2Body *holderBody2 = world->CreateBody(&holderBodyDef2);
//        
//        b2PolygonShape holderBox2;
//        holderBox2.SetAsBox(.25f, .25f);
//        
//        b2Fixture *holderFixture2 = holderBody2->CreateFixture(&holderBox2,0);
//        holderFixture2->SetFilterData(holderFilter);
//        
//        
//        CGPoint p = ccp(holderBody->GetPosition().x*PTM_RATIO, holderBody->GetPosition().y*PTM_RATIO);
//        CCSprite *rope = [CCSprite spriteWithFile:@"rope.png"];
//        rope.position = p;
//        
//        CCLOG(@"rope pos=(%f, %f)\n", p.x, p.y);
//        [self addChild:rope];
//        
//        b2BodyDef bodyDef;
//        bodyDef.type = b2_dynamicBody;
//        
//        bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
//        bodyDef.userData = rope;
//        b2Body *ropeBody = world->CreateBody(&bodyDef);
//        
//        // Define another box shape for our dynamic body.
//        b2PolygonShape dynamicBox;
//        dynamicBox.SetAsBox([rope boundingBox].size.width/PTM_RATIO/2, [rope boundingBox].size.height/PTM_RATIO/2);//These are mid points for our 1m box
//        
//        // Define the dynamic body fixture.
//        b2FixtureDef fixtureDef;
//        fixtureDef.shape = &dynamicBox;	
//        fixtureDef.density = 1.5f;
//        fixtureDef.friction = 0.3f;
//        b2Fixture *ropeFixture = ropeBody->CreateFixture(&fixtureDef);
//        b2Filter ropeFilter;
//        ropeFilter.categoryBits = CATEGORY_ROPE;
//        ropeFilter.maskBits = 0;
//        ropeFixture->SetFilterData(ropeFilter);
//        
//        // create a revolute joint with a motor
//        minAngleRads = -45*(M_PI/180.0);
//        maxAngleRads = 45*(M_PI/180.0);
//        
//        b2RevoluteJointDef revJointDef;
//        revJointDef.Initialize(holderBody, ropeBody, holderBody->GetWorldCenter());
//        
//        revJointDef.localAnchorB = b2Vec2(0, ([rope boundingBox].size.height/PTM_RATIO/2.1));
//        revJointDef.motorSpeed = MOTOR_SPEED;
//        revJointDef.lowerAngle = minAngleRads;
//        revJointDef.upperAngle = maxAngleRads;
//        revJointDef.enableLimit = YES;
//        revJointDef.maxMotorTorque = 100000000;
//        revJointDef.referenceAngle = 0;
//        revJointDef.enableMotor = YES;
//        revJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
//        
//        
//        // 2nd rope
//        CGPoint p2 = ccp(holderBody2->GetPosition().x*PTM_RATIO, holderBody2->GetPosition().y*PTM_RATIO);
//        CCSprite *rope2 = [CCSprite spriteWithFile:@"rope.png"];
//        //        rope.anchorPoint = ccp(0.5, 1);  // top edge is the anchor
//        rope2.position = p2;
//        
//        [self addChild:rope2];
//        
//        b2BodyDef bodyDef2;
//        bodyDef2.type = b2_dynamicBody;
//        
//        bodyDef2.position.Set(p2.x/PTM_RATIO, p2.y/PTM_RATIO);
//        bodyDef2.userData = rope2;
//        b2Body *ropeBody2 = world->CreateBody(&bodyDef2);
//        
//        // Define another box shape for our dynamic body.
//        b2PolygonShape dynamicBox2;
//        dynamicBox2.SetAsBox([rope2 boundingBox].size.width/PTM_RATIO/2, [rope2 boundingBox].size.height/PTM_RATIO/2);//These are mid points for our 1m box
//        
//        // Define the dynamic body fixture.
//        b2FixtureDef fixtureDef2;
//        fixtureDef2.shape = &dynamicBox2;	
//        fixtureDef2.density = 1.5f;
//        fixtureDef2.friction = 0.3f;
//        b2Fixture *ropeFixture2 = ropeBody2->CreateFixture(&fixtureDef2);
//        b2Filter ropeFilter2;
//        ropeFilter2.categoryBits = CATEGORY_ROPE;
//        ropeFilter2.maskBits = 0;
//        ropeFixture2->SetFilterData(ropeFilter2);
//        
//        
//        b2RevoluteJointDef revJointDef2;
//        revJointDef2.Initialize(holderBody2, ropeBody2, holderBody2->GetWorldCenter());
//        
//        revJointDef2.localAnchorB = b2Vec2(0, ([rope2 boundingBox].size.height/PTM_RATIO/2.1));
//        revJointDef2.motorSpeed = -MOTOR_SPEED*1.5f;
//        revJointDef2.lowerAngle = minAngleRads;
//        revJointDef2.upperAngle = maxAngleRads;
//        revJointDef2.enableLimit = YES;
//        revJointDef2.maxMotorTorque = 100000000;
//        revJointDef2.referenceAngle = 0;
//        revJointDef2.enableMotor = YES;
//        revJoint2 = (b2RevoluteJoint *)world->CreateJoint(&revJointDef2);
//        
//        
//        
//        
//        
//        
//        // create the catcher (swinging dude)
//        CGPoint catcherPos = ccp(rope.position.x, rope.position.y - [rope boundingBox].size.height/2.1);
//        CCSprite *catcher = [CCSprite spriteWithFile:@"catcher.png"];
//        catcher.position = catcherPos;
//        [self addChild:catcher];
//        
//        b2BodyDef catcherBodyDef;
//        catcherBodyDef.type = b2_dynamicBody;
//        catcherBodyDef.position.Set(catcherPos.x/PTM_RATIO, catcherPos.y/PTM_RATIO);
//        catcherBodyDef.userData = catcher;
//        catcherBody = world->CreateBody(&catcherBodyDef);
//        
//        b2PolygonShape catcherBox;
//        catcherBox.SetAsBox([catcher boundingBox].size.width/PTM_RATIO/2, [catcher boundingBox].size.height/PTM_RATIO/2);
//        
//        b2FixtureDef catcherFixtureDef;
//        catcherFixtureDef.shape = &catcherBox;
//        catcherFixtureDef.density = 1.0f;
//        catcherFixtureDef.friction = 0.3f;
//        catcherFixtureDef.isSensor = YES;
//        
//        b2Fixture *catcherFixture = catcherBody->CreateFixture(&catcherFixtureDef);
//        b2Filter catcherFilter;
//        catcherFilter.categoryBits = CATEGORY_CATCHER;
//        catcherFilter.maskBits = CATEGORY_JUMPER;
//        catcherFixture->SetFilterData(catcherFilter);
//        
//        
//        b2WeldJointDef catcherJointDef;
//        catcherJointDef.Initialize(ropeBody, catcherBody, catcherBody->GetWorldCenter());
//        
//        catcherJointDef.collideConnected = NO;
//        catcherJointDef.bodyA = ropeBody;
//        catcherJointDef.bodyB = catcherBody;
//        catcherJointDef.localAnchorA = b2Vec2(0, 0);
//        catcherJointDef.localAnchorB = b2Vec2(0,[catcher boundingBox].size.height/PTM_RATIO/2*.8);
//        world->CreateJoint(&catcherJointDef);
//        
//        
//        
//        
//        // create the catcher (swinging dude), #2
//        CGPoint catcherPos2 = ccp(rope2.position.x, rope2.position.y - [rope2 boundingBox].size.height/2.1);
//        CCSprite *catcher2 = [CCSprite spriteWithFile:@"catcher.png"];
//        catcher2.position = catcherPos2;
//        [self addChild:catcher2];
//        
//        b2BodyDef catcherBodyDef2;
//        catcherBodyDef2.type = b2_dynamicBody;
//        catcherBodyDef2.position.Set(catcherPos2.x/PTM_RATIO, catcherPos2.y/PTM_RATIO);
//        catcherBodyDef2.userData = catcher2;
//        b2Body *catcherBody2 = world->CreateBody(&catcherBodyDef2);
//        
//        b2PolygonShape catcherBox2;
//        catcherBox2.SetAsBox([catcher2 boundingBox].size.width/PTM_RATIO/2, [catcher2 boundingBox].size.height/PTM_RATIO/2);
//        
//        b2FixtureDef catcherFixtureDef2;
//        catcherFixtureDef2.shape = &catcherBox2;
//        catcherFixtureDef2.density = 1.0f;
//        catcherFixtureDef2.friction = 0.3f;
//        catcherFixtureDef2.isSensor = YES;
//        
//        b2Fixture *catcherFixture2 = catcherBody2->CreateFixture(&catcherFixtureDef2);
//        b2Filter catcherFilter2;
//        catcherFilter2.categoryBits = CATEGORY_CATCHER;
//        catcherFilter2.maskBits = CATEGORY_JUMPER;
//        catcherFixture2->SetFilterData(catcherFilter2);
//        
//        b2WeldJointDef catcherJointDef2;
//        catcherJointDef2.Initialize(ropeBody2, catcherBody2, catcherBody2->GetWorldCenter());
//        
//        catcherJointDef2.collideConnected = NO;
//        catcherJointDef2.bodyA = ropeBody2;
//        catcherJointDef2.bodyB = catcherBody2;
//        catcherJointDef2.localAnchorA = b2Vec2(0, 0);
//        catcherJointDef2.localAnchorB = b2Vec2(0,[catcher2 boundingBox].size.height/PTM_RATIO/2*.8);
//        world->CreateJoint(&catcherJointDef2);
        
        baseXDelta = screenSize.width*.4;
        catcherXPos = -(screenSize.width*.2);
        catcherYPos = screenSize.height*.75;
        
        SwingingRopeDude *firstCatcher = [self createNextCatcher];
        for (int i=0; i < 10; i++) {
            [self createNextCatcher];
        }
        
        
//        CGPoint pos1 = ccp(screenSize.width*.25, screenSize.height*.75);
//        CGPoint pos2 = ccp(screenSize.width*.75, screenSize.height*.75);
//        SwingingRopeDude *rope1 = [[SwingingRopeDude alloc] initWithParent:self at:pos1 withSpeed:3.f];
//        SwingingRopeDude *rope2 = [[SwingingRopeDude alloc] initWithParent:self at:pos2 withSpeed:4.f];
//        [rope1 createPhysicsObject:world];
//        [rope2 createPhysicsObject:world];
        
        
        // create the jumper
        CCSprite *catcher = firstCatcher.catcherSprite;
        finishScrolling = NO;
        leadOut = screenSize.width*.6;

        CGPoint jumperPos = ccp(catcher.position.x, catcher.position.y - [catcher boundingBox].size.height*.7);
        jumper = [[JumpingDude alloc] initWithParent:self];
        [jumper createPhysicsObject:world at:jumperPos];

//        CCSprite *jumper = [CCSprite spriteWithFile:@"jumper.png"];
//        jumper.position = jumperPos;
//        [self addChild:jumper];
//        
//        b2BodyDef jumperBodyDef;
//        jumperBodyDef.type = b2_dynamicBody;
//        jumperBodyDef.position.Set(jumperPos.x/PTM_RATIO, jumperPos.y/PTM_RATIO);
//        jumperBodyDef.userData = jumper;
//        jumperBody = world->CreateBody(&jumperBodyDef);
//        
//        b2PolygonShape jumperBox;
//        jumperBox.SetAsBox([jumper boundingBox].size.width/PTM_RATIO/2, [jumper boundingBox].size.height/PTM_RATIO/2);
//        
//        b2FixtureDef jumperFixtureDef;
//        jumperFixtureDef.shape = &jumperBox;
//        jumperFixtureDef.density = 1.0f;
//        jumperFixtureDef.friction = 0.3f;
//        
//        b2Fixture *jumperFixture = jumperBody->CreateFixture(&jumperFixtureDef);
//        b2Filter jumperFilter;
//        jumperFilter.categoryBits = CATEGORY_JUMPER;
//        jumperFilter.maskBits = CATEGORY_CATCHER;
//        jumperFixture->SetFilterData(jumperFilter);
        
        
        // attach the jumper to the first rope
        nextCatcher = firstCatcher;
        jumperJoint = NULL;
        [self createJumperJoint];
        nextCatcher = nil;
        
//        b2WeldJointDef jumperJointDef;
//        b2Vec2 jjPos = catcherBody->GetWorldCenter();
//        jjPos.y -= [catcher boundingBox].size.height/PTM_RATIO*.75;
//        jumperJointDef.Initialize(catcherBody, jumper.body, jjPos);
//        jumperJoint = world->CreateJoint(&jumperJointDef);
                
        
		[self schedule: @selector(tick:)];
	}
	return self;
}

   
- (SwingingRopeDude *) createNextCatcher {
    catcherXPos += (baseXDelta*(1 + (CCRANDOM_0_1()/5)));
    
    SwingingRopeDude *rope = [[SwingingRopeDude alloc] initWithParent:self at:ccp(catcherXPos, catcherYPos) withSpeed:baseSpeed];
    [rope createPhysicsObject:world];
    
    // increase the base speed
    baseSpeed *= 1.1f;
    
    return rope;
}

- (void) catchJumper:(SwingingRopeDude *)catcher {
    
    if (catcher != lastCatcher)
        nextCatcher = catcher;
}

- (void) createJumperJoint {
    
    //XXX don't think it's possible to get here if it's non null
    if (jumperJoint == NULL) {
        targetScrollPos = -(nextCatcher.catcherSprite.position.x - leadOut);
        lastCatcher = nextCatcher;
        lastJumperPos = jumper.sprite.position.x;
//        scrollVel = jumper.body->GetLinearVelocity().x;
        
//        b2WeldJointDef jumperJointDef;
//        b2Vec2 jjPos = nextCatcher.catcherBody->GetWorldCenter();
//        jjPos.y -= [(nextCatcher.catcherSprite) boundingBox].size.height/PTM_RATIO*.75;
//        jumperJointDef.Initialize(nextCatcher.catcherBody, jumper.body, jjPos);
//        jumperJoint = world->CreateJoint(&jumperJointDef);
        
        b2RevoluteJointDef revJointDef;
        b2Vec2 jjPos = nextCatcher.catcherBody->GetWorldCenter();
        jjPos.y -= [(nextCatcher.catcherSprite) boundingBox].size.height/PTM_RATIO*.75;
        revJointDef.Initialize(nextCatcher.catcherBody, jumper.body, jjPos);
        
        // set the anchor for the rope to be the top and bottom edges
        revJointDef.localAnchorA = b2Vec2(0,-[(nextCatcher.catcherSprite) boundingBox].size.height/PTM_RATIO*.8);
        revJointDef.localAnchorB = b2Vec2(0, [(jumper.sprite) boundingBox].size.height/PTM_RATIO*.2);
//        revJointDef.localAnchorB = b2Vec2(0, ([ropeSprite boundingBox].size.height/PTM_RATIO/2.1));
        revJointDef.lowerAngle = -10*(M_PI/180.0);
        revJointDef.upperAngle = 10*(M_PI/180.0);
        revJointDef.enableLimit = YES;
        revJointDef.referenceAngle = 0;
        revJointDef.enableMotor = NO;
        jumperJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
    } else {
        CCLOG(@"\n\n####   In createJumperJoint but jumperJoint is non-NULL!!!!   #####\n\n");
    }
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
    
//    b2DistanceJointDef jointDef;
//    jointDef.Initialize(holderBody, body, holderBody->GetWorldCenter(), body->GetWorldCenter());
//    
//    world->CreateJoint(&jointDef);
}



-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

//    // update the jumper
//    [jumper updateObject:dt];
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
            CCNode<GameObject> *gameObject = (CCNode<GameObject>*)b->GetUserData();
            
            switch ([gameObject gameObjectType]) {
                case kGameObjectCatcher:
                case kGameObjectJumper:
                    [gameObject updateObject:dt];
                    break;
                default:
                    break;
            }
		}	
	}

    
//    SwingingRopeDude *rope;
//    CCARRAY_FOREACH(ropes, rope) {
//        [rope updateObject:dt];
//    }
    

    // If the jumper should be caught, create the joint now
    if (nextCatcher != nil) {
        [self createJumperJoint];
        nextCatcher = nil;
    }
    
    if (jumperJoint == NULL) {
        float newX = -(jumper.sprite.position.x - leadoutOffset);
        scrollDelta = self.position.x - newX;
        CCLOG(@"  SCROLLING: curr self=%f, player=%f, leadout=%f, new=%f\n", self.position.x, jumper.sprite.position.x, leadoutOffset, -(jumper.sprite.position.x - leadoutOffset));

        self.position = ccp(newX, self.position.y);
    } else if (finishScrolling) {
        CCLOG(@"finish scrolling: pos=%f, target=%f, delta=%f, new=%f\n", self.position.x, targetScrollPos, scrollDelta, (self.position.x + scrollDelta));
        if ((scrollDelta > 0 && self.position.x > targetScrollPos) ||
            (scrollDelta < 0 && self.position.x < targetScrollPos)) {

//            self.position = ccp(self.position.x - scrollDelta, self.position.y);            
        } else {
            finishScrolling = NO;
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (jumperJoint != NULL) {
        
        // only set this for the first jump
        if (leadoutOffset == 0) {
            leadoutOffset = jumper.sprite.position.x - self.position.x;
        } else {
            // account for the difference between where the offset was when the jumper
            // was caught, and where the jumper is now (will be different due to the
            // swinging rope)
            leadoutOffset += (jumper.sprite.position.x - lastJumperPos);
        }
        
        //XXX is it safe to just destroy this here or does this need to happen in update?
        world->DestroyJoint(jumperJoint);
        jumperJoint = NULL;
        finishScrolling = YES;
        
        CCLOG(@"\n\n#####  Updating leadout from %f to %f  #####\n\n", leadoutOffset, jumper.sprite.position.x - self.position.x);

    }
    
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		
//		location = [[CCDirector sharedDirector] convertToGL: location];
//		
//		[self addNewSpriteWithCoords: location];
//	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end

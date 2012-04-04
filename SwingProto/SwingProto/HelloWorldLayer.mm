//
//  HelloWorldLayer.mm
//  SwingProto
//
//  Created by James Sandoz on 3/11/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

#import "SwingingRopeDude.h"
#import "JumpingDude.h"


// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

#define MIN_SCROLL_DELTA 3

@interface HelloWorldLayer(Private)
- (void) initGame;
- (void) cleanupGame;
@end

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
		
		screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -30.0f);
		
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
        
        
        [self initGame];
	}
	return self;
}

- (void) initGame {
    
    baseSpeed = 3;
    baseXDelta = screenSize.width*.5;
    catcherXPos = screenSize.width*.25;
    catcherYPos = screenSize.height*.9;
    
    CGPoint startPos = ccp(screenSize.width*.25, screenSize.height*.9);
    
//    SwingingRopeDude *firstCatcher = [self createNextCatcher];
//    for (int i=0; i < 10; i++) {
//        [self createNextCatcher];
//    }
    SwingingRopeDude *firstCatcher = [[SwingingRopeDude alloc] initWithParent:self at:startPos withSpeed:3];
    [firstCatcher createPhysicsObject:world];
    
    // create the jumper
    CCSprite *catcher = firstCatcher.catcherSprite;
    finishScrolling = NO;
    needToScroll = NO;
    leadOut = screenSize.width*.6;
    
    newCatcher = [self createNextCatcher];
    offscreenCatcher = [self createNextCatcher];
    
    CGPoint jumperPos = ccp(catcher.position.x, catcher.position.y - [catcher boundingBox].size.height*.7);
    jumper = [[JumpingDude alloc] initWithParent:self];
    [jumper createPhysicsObject:world at:jumperPos];

    cleanupCatcher = nil;
    nextCatcher = firstCatcher;
    jumperJoint = NULL;
    [self createJumperJoint];
    nextCatcher = nil;
    
    [self schedule: @selector(tick:)];
}

- (void) cleanupGame {
    self.position = ccp(0,0);
}
   
- (SwingingRopeDude *) createNextCatcher {
    catcherXPos += baseXDelta;
    
    SwingingRopeDude *rope = [[SwingingRopeDude alloc] initWithParent:self at:ccp(catcherXPos, catcherYPos) withSpeed:baseSpeed];
    [rope createPhysicsObject:world];
    
    // increase the base speed
    baseSpeed *= 1.1f;
    
    return rope;
}

- (void) catchJumper:(SwingingRopeDude *)catcher at:(ContactLocation)location{
    
    if (catcher != lastCatcher) {
        catchSide = location;
        nextCatcher = catcher;
    }
}

- (void) createJumperJoint {
    
    //XXX don't think it's possible to get here if it's non null
    if (jumperJoint == NULL) {
//        targetScrollPos = -(nextCatcher.catcherSprite.position.x + screenSize.width*.25);
//        + leadOut);
        
        CCLOG(@"  curr pos=%f, nextCatcher pos=%f, leadout=%f, target pos=%f\n", self.position.x, nextCatcher.catcherSprite.position.x, leadOut, targetScrollPos);
        lastCatcher = nextCatcher;
        lastJumperPos = jumper.sprite.position.x;
//        scrollVel = jumper.body->GetLinearVelocity().x;
        
        b2RevoluteJointDef revJointDef;
        b2Vec2 jjPos = nextCatcher.catcherBody->GetWorldCenter();
        jjPos.y -= [(nextCatcher.catcherSprite) boundingBox].size.height/PTM_RATIO*.75;
        revJointDef.Initialize(nextCatcher.catcherBody, jumper.body, jjPos);
        
        // set the anchor for the rope to be the top and bottom edges
        revJointDef.localAnchorA = b2Vec2(0,-[(nextCatcher.catcherSprite) boundingBox].size.height/PTM_RATIO*.8);
        
        // Set the anchor to be the appropriate side of the jumper
        if (catchSide == kContactTop) {
            CCLOG(@"  creating joint at top\n");
            revJointDef.referenceAngle = 0;
            revJointDef.localAnchorB = b2Vec2(0, [(jumper.sprite) boundingBox].size.height/PTM_RATIO*.2);
        } else {
            CCLOG(@"  creating joint at bottom\n");
            revJointDef.referenceAngle = 180*(M_PI/180.0);
            revJointDef.localAnchorB = b2Vec2(0, [(jumper.sprite) boundingBox].size.height/PTM_RATIO*-.2);
        }
//        revJointDef.localAnchorB = b2Vec2(0, ([ropeSprite boundingBox].size.height/PTM_RATIO/2.1));
        revJointDef.lowerAngle = -10*(M_PI/180.0);
        revJointDef.upperAngle = 10*(M_PI/180.0);
        revJointDef.enableLimit = YES;
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
    // if the jumper fell below the screen, stop now
    if (jumper.sprite.position.y < -200) {
//        [self unscheduleAllSelectors];
        [self cleanupGame];
        return;
    }
    
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	
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

    // If the jumper should be caught, create the joint now
    if (nextCatcher != nil) {
        [self createJumperJoint];
        nextCatcher = nil;
    }
    
    if (needToScroll) {
        
        BOOL doCleanup = NO;
        
        if (jumperJoint == NULL) {
            float newX = -(jumper.sprite.position.x - leadoutOffset);
            
            // only scroll forwards, and stop scrolling once we reach the next catcher
            if (newX < self.position.x ) {
                scrollDelta = self.position.x - newX;
                if (scrollDelta < MIN_SCROLL_DELTA)
                    scrollDelta = MIN_SCROLL_DELTA;
                
                if (newX < targetScrollPos) {
                    newX = targetScrollPos;
                    doCleanup = YES;
                }
            
    //        CCLOG(@"  SCROLLING: curr self=%f, player=%f, leadout=%f, new=%f\n", self.position.x, jumper.sprite.position.x, leadoutOffset, -(jumper.sprite.position.x - leadoutOffset));

                self.position = ccp(newX, self.position.y);
            }
        } else if (finishScrolling) {
    //        CCLOG(@"finish scrolling: pos=%f, target=%f, delta=%f, new=%f\n", self.position.x, targetScrollPos, scrollDelta, (self.position.x - scrollDelta));
            if ((scrollDelta > 0 && self.position.x > targetScrollPos) ||
                (scrollDelta < 0 && self.position.x < targetScrollPos)) {

                self.position = ccp(self.position.x - scrollDelta, self.position.y);            
            } else {
                doCleanup = YES;
            }
        }
        
        if (doCleanup) {
            CCLOG(@"=== Cleaning up catcher and creating new offscreen catcher ===\n");
            finishScrolling = NO;
            needToScroll = NO;
            
            if (cleanupCatcher != nil) {
                [cleanupCatcher dealloc];
                cleanupCatcher = nil;
            }
            
            newCatcher = offscreenCatcher;
            offscreenCatcher = [self createNextCatcher];
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (jumperJoint != NULL) {
        
        // determine the offset between the player position and the screen position.  This
        // offset exists because the player is swinging and the screen is centered on the 
        // rope, not the jumper
        leadoutOffset = jumper.sprite.position.x - (-1*self.position.x);
        
        //XXX is it safe to just destroy this here or does this need to happen in update?
        //XXX seems safe so far but I'm not 100% convinced
        world->DestroyJoint(jumperJoint);
        jumperJoint = NULL;
        finishScrolling = YES;
        cleanupCatcher = lastCatcher;
        needToScroll = YES;
        targetScrollPos = -(newCatcher.catcherSprite.position.x - screenSize.width*.25);
        
        CCLOG(@"\n\n###  JUMPING!  self pos=%f, curr catcher=%f, newCatcher=%f, targetScrollPos=%f  ###\n\n", self.position.x, lastCatcher.catcherSprite.position.x, newCatcher.catcherSprite.position.x, targetScrollPos);
    }
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

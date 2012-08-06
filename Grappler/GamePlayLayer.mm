//
//  GamePlayLayer.mm
//  Grappler
//
//  Created by James Sandoz on 8/1/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GamePlayLayer.h"

#import "Constants.h"
#import "Player.h"
#import "VRope.h"


// GamePlayLayer implementation
@implementation GamePlayLayer

static GamePlayLayer* instanceOfGamePlayLayer;

#pragma mark - Initialization
+(GamePlayLayer*) sharedLayer {
	NSAssert(instanceOfGamePlayLayer != nil, @"GamePlayLayer instance not yet initialized!");
	return instanceOfGamePlayLayer;
}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayLayer *layer = [GamePlayLayer node];
	
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
		
		screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        
        instanceOfGamePlayLayer = self;
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
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
        
        UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
        longPress.allowableMovement = 25;
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:longPress];
		
        // Initial starting position
        CGPoint playerStartPos = ccp(screenSize.width*.4, screenSize.height*.3);
        
        player = [Player spriteWithFile:@"gorilla.png"];
        player.scale = 0.5f;
        [player createPhysicsObject:world];
        [self addChild:player];
        [player showAt:playerStartPos];
        player.maxRopeLength = screenSize.height*.5/PTM_RATIO;        
        
        // Create the rope holder body.  The player will be attached to this via
        // a line joint, and a mouse joint will move this around
        CGPoint holderStartPos = ccp(screenSize.width*.5, screenSize.height*.75);
        b2BodyDef ropeAnchorBodyDef;
        ropeAnchorBodyDef.type = b2_staticBody;
        ropeAnchorBodyDef.position.Set(holderStartPos.x/PTM_RATIO, holderStartPos.y/PTM_RATIO);
        ropeAnchor = world->CreateBody(&ropeAnchorBodyDef);
        
        // Define another box shape for our dynamic body.
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(.25f, .25f);//These are mid points for our 1m box
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;	
        fixtureDef.density = 10.0f;
        fixtureDef.friction = 0.f;
        fixtureDef.filter.categoryBits = CATEGORY_ANCHOR;
        fixtureDef.filter.maskBits = CATEGORY_ANCHOR;
        ropeAnchor->CreateFixture(&fixtureDef);
        
        // Create the verlet rope spritesheet
        ropeSegmentSprite = [CCSpriteBatchNode batchNodeWithFile:@"rope.png"];
        [self addChild:ropeSegmentSprite];
        
        // Attach the player to the ropeAnchor
        [player swingFrom:ropeAnchor];
        
        // Create the verlet rope
        [self createVRope];

        [self scheduleUpdate];
	}
	return self;
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
    
    if (vrope != nil) {
        [vrope updateSprites];
    }
}

- (void) createVRope {
    if (player != nil && ropeAnchor != nil) {
        vrope = [[VRope alloc] init:[player getPhysicsBody] body2:ropeAnchor spriteSheet:ropeSegmentSprite];
    }
}

// Called by player to indicate that the length of the distance joint has
// changed and the rope should be updated
- (void) updateVRope {
    // destroy the rope
    if (vrope != nil) {
        [vrope removeSprites];
        [vrope release];
    }
    
    [self createVRope];
}


- (void) handleScreenScroll:(ccTime)dt {
    
    float deltaXScroll = 0.f;
    float deltaYScroll = 0.f;
    
    if (player.currentAnchor != NULL) {
        
        // Center the screen around the rope anchor
        if (player.currentAnchor->GetPosition().x*PTM_RATIO > (-self.position.x + screenSize.width*.51f)) {
            deltaXScroll = 200 * dt;
        } else if (player.currentAnchor->GetPosition().x*PTM_RATIO < (-self.position.x + screenSize.width*.49f)) {
            deltaXScroll = -200 * dt;
        }
        
        // For the y position put the rope anchor at 60% of the screen height
        if (player.currentAnchor->GetPosition().y*PTM_RATIO > (-self.position.y + screenSize.height*.61f)) {
            
            deltaYScroll = 200 *dt;
            
        } else if (player.currentAnchor->GetPosition().y*PTM_RATIO < (-self.position.y + screenSize.height*.59f)) {
            
            deltaYScroll = -200 *dt;
        }
    } else {
        // With no anchor, scroll to keep the player on screen
        if (player.position.x > (-self.position.x + screenSize.width*.75f)) {
            deltaXScroll = 400 * dt;
            
        } else if (player.position.x < (-self.position.x + screenSize.width*.25f)) {
            deltaXScroll = -400 * dt;
        }
        
        if (player.position.y > (-self.position.y + screenSize.height*.6f)) {
            deltaYScroll = 400 * dt;
            
        } else if (player.position.y < (-self.position.y + screenSize.height*.25f)) {
            deltaYScroll = -400 * dt;
        }
        
        if (deltaXScroll != 0 || deltaYScroll != 0) {
            CCLOG(@"Scrolling player by (%f,%f):  player pos=(%f,%f), self pos=(%f,%f), x bounds=[%f,%f], y bounds=[%f,%f]\n",
                                    deltaXScroll, deltaYScroll,
                player.position.x, player.position.y, self.position.x, self.position.y,
                (-self.position.x + screenSize.width*.25f),
                (-self.position.x + screenSize.width*.75f),
                (-self.position.y + screenSize.height*.25f),
                (-self.position.y + screenSize.height*.75f));
            
        }
    }
    
    self.position = ccp(self.position.x - deltaXScroll, self.position.y - deltaYScroll);
}


- (void) update:(ccTime)dt {
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
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
		if (b->GetUserData() != NULL) {
            
            CCNode<GameObject> *go = (CCNode<GameObject> *)b->GetUserData();
            switch ([go gameObjectType]) {
                case kGameObjectPlayer:
                    [go updateObject:dt];
                    break;
                default:
                    break;
            }
		}	
	}
    
    // If the player is holding down the tap button then shorten the rope
    //XXX also apply a force?
    if (player.currentAnchor != NULL && isHolding) {
        [player shortenRope:dt];
        [self updateVRope];
    }
    
    if (vrope != nil) {
        [vrope update:dt];
    }
    
    [self handleScreenScroll:dt];
}

//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"In ccTouchesBegan\n");
    
	// just take the last touch
	UITouch *lastTouch = [[touches allObjects] lastObject];
    CGPoint location = [lastTouch locationInView:[lastTouch view]];

    location = [[CCDirector sharedDirector] convertToGL: location];
    
    // Adjust the location to account for scrolling
//    if (self.position.x < 0) {
        location.x -= self.position.x;
//    } else {
//        location.x -= self.position.x;
//    }
    
//    if (self.position.y < 0) {
        location.y -= self.position.y;
//    }
    
    // If there is currently a rope joint, destroy it.  otherwise create a
    // rope joint where the player touched
    
    // Destroy the existing joint, move the anchor, then attach the player to
    // the anchor
    if (player.currentAnchor != NULL) {
        [player destroyRopeJoint];
        [vrope removeSprites];
        [vrope release];
        vrope = nil;
    } else {
        ropeAnchor->SetTransform(b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO), 0);
        [player swingFrom:ropeAnchor];
        
        // Create the verlet rope
        [self createVRope];
    }
}


- (void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CCLOG(@"In handleLongPress, state=%d\n", [gestureRecognizer state]);
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        isHolding = YES;
    } else if ([gestureRecognizer state] != UIGestureRecognizerStateChanged) {
        isHolding = NO;
    }
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

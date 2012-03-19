//
//  HelloWorldLayer.mm
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright GAMEPEONS LLC 2012. All rights reserved.
//


// Import the interfaces
#import "GameplayLayer.h"
#import "Constants.h"
#import "Player.h"
#import "Energy.h"


// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation GameplayLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
	
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
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		[PhysicsWorld createInstance];
        physicsWorld = [PhysicsWorld sharedWorld];
        world = [physicsWorld getWorld];
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
//		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
//		groundBody->CreateFixture(&groundBox,0);
//		
//		// left
//		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
//		groundBody->CreateFixture(&groundBox,0);
//		
//		// right
//		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
//		groundBody->CreateFixture(&groundBox,0);
		
        
        player = [Player spriteWithFile:@"blocks.png"];
        player.position = ccp(160, 20);
        player.scale = 0.75;
        [player createPhysicsObject:world];
        [self addChild:player];

        for (int i = 0; i < 200; i++) {
            Energy *energy = [Energy spriteWithFile:@"food.png"];
            energy.position = ccp(arc4random() % 320,  80*i);
            [energy createPhysicsObject:world];
            [self addChild:energy z:-1];
        }
        
		//CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		//[self addChild:batch z:0 tag:kTagBatchNode];
		
	
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

    glPushMatrix();
    glScalef( CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
    world->DrawDebugData();
    glPopMatrix();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}



-(void) update:(ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/	
    
    [physicsWorld step:dt];

    [player updateObject:dt withAccelX:accelX];

    //Iterate over the bodies in the physics world
//    b2Body *_node = world->GetBodyList();
//    while (_node) {
//        b2Body *_body = _node;
//        _node = _node->GetNext();        
//		CCNode<GameObject> *_gameObject = (CCNode<GameObject>*)_body->GetUserData();
//		if (_gameObject != NULL) {
//            //if ([_gameObject conformsToProtocol:@protocol(GameObject)]) {
//            //    CCLOG(@"-------------------------------------------------------------------------------> %d", [_gameObject gameObjectType]);
//            //}
//            switch ([_gameObject gameObjectType]) {
//                    [_gameObject updateObject:dt];
//                    break;
//                default:
//                    break;
//            }            
//		}
//	}	
    
    
    if (player.position.y > 240) {
        self.position = ccp(self.position.x, -player.position.y + 240);
    } else {
        self.position = ccp(self.position.x, 0);        
    }

}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [player jump];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
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
	
    //	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
    //	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    //	
    //	prevX = accelX;
    //	prevY = accelY;
    //	
    //	// accelerometer values are in "Portrait" mode. Change them to Landscape left
    //	// multiply the gravity by 10
    //	b2Vec2 gravity( accelX * 50, -9.8);
    //	
    //	world->SetGravity( gravity );
    
    accelX = acceleration.x;
    
    //    float sensitivity = 10;
    //    
    //    float velocityX = sensitivity * (powf((-fabsf(acceleration.x) + 0.5), 2.0) - 1.25) * -acceleration.x;
    //    float velocityY = sensitivity * (powf((-fabsf(acceleration.y) + 0.5), 2.0) - 1.25) * -acceleration.x;
    //    accelX = velocityX;
    //    CCLOG(@"%f", velocityX);
    //    
    //    if (accelX < -0.5) accelX = -0.25;
    //    else if (accelX > 0.5) accelX = 0.25;
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

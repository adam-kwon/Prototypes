//
//  GamePlayLayer.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Constants.h"
#import "GamePlayLayer.h"
#import "MainGameScene.h"
#import "Meteor.h"
#import "PowerUpDoubleJump.h"
#import "PowerUpSpeedBoostExtender.h"
#import "PowerUpSpeedBoost.h"
#import "PowerUpFlight.h"
#import "PowerUp.h"
#import "Runner.h"
#import "SimpleAudioEngine.h"
#import "ParallaxBackgroundLayer.h"
#import "UserInterfaceLayer.h"
#import "Crow.h"
#import "StaticBackgroundLayer.h"
#import "GameRules.h"

GameRules rules;

typedef enum {
    kPowerUpToAddNone,
    kPowerUpToAddSpeedBoostX1,
    kPowerUpToAddSpeedBoostX2,
    kPowerUpToAddSpeedBoostExtender,
    kPowerUpToAddDoubleJump,
    kPowerUpToAddFlight
} PowerUpToAdd;

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;

// Minimum remaining time to avoid box2d unstability caused by very small delta times
// if remaining time to simulate is smaller than this, the rest of time will be added to the last step,
// instead of performing one more single step with only the small delta time.
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  

const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;

// maximum number of steps per tick to avoid spiral of death
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

const int swipeTolerance = 40;

// Private methods
@interface GamePlayLayer(Private) 
- (void) createBuildings;
- (void) moveBuildingAfter:(Building *) b;
- (PowerUpToAdd) getPowerUpToAdd;
- (int) calculateGap:(PowerUpToAdd)powerUpToAdd;
- (void) addPowerup:(PowerUpToAdd)powerUpToAdd toLeftBuilding:(Building*)left andRightBuilding:(Building*)right;
- (void) destroyTileMapBodies:(CCTMXTiledMap *)map withKey:(NSNumber *)key;
- (void) addRandomTileMap;
- (void) makeBox2dObjAt:(CGPoint)p 
              withSize:(CGPoint)size 
               dynamic:(BOOL)d 
              rotation:(long)r 
              friction:(long)f 
               density:(long)dens 
           restitution:(long)rest 
                 boxId:(int)boxId;
- (void) drawCollisionTiles:(int)x_offset;
- (void) setupSounds;
- (void) sendMeteor;
- (void) queueMeteorShower;
- (void) initGameRules;
- (void) createLetterbox;
- (void) startLiftingLetterbox;
- (void) introEffect;
- (BOOL) isSwipeUp;
#ifdef DEBUG
- (int) numActiveBuildings;
#endif
// -(void) createBridgeFrom:(Building*)b1 to:(Building*)b2;
@end    


@implementation GamePlayLayer

@synthesize gameOver;
@synthesize screenSize;
@synthesize meteor;
@synthesize killerMeteorQueued;

static GamePlayLayer* instanceOfGamePlayLayer;

#pragma mark -
#pragma mark Initialization
+(GamePlayLayer*) sharedLayer {
	NSAssert(instanceOfGamePlayLayer != nil, @"GamePlayLayer instance not yet initialized!");
	return instanceOfGamePlayLayer;
}

// initialize your instance here
-(id) init {
	if ((self=[super init])) {
        [self setIsTouchEnabled:YES];
        [self initGameRules];
        [self setIsRelativeAnchorPoint:YES];
        [self setAnchorPoint:CGPointZero];
        instanceOfGamePlayLayer = self;
		gameOver = false;
        calledDisplayGameOver = NO;
        preCleanup = NO;
        leadout_offset = -100.0f;
        letterBoxIncrement = 0.0;
        letterBoxShowing = YES;
        startLiftingLetterbox = NO;
        screenSize = [CCDirector sharedDirector].winSize;
        buildingsSinceLastDoubleJump = 0;
        buildingsSinceLastSpeedBoostX1 =  0;
        buildingsSinceLastSpeedBoostX2 = 0;
        buildingsSinceLastSpeedExtender = 0;
        buildingsSinceLastFlight = 0;
        mainBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"ForegroundPlayerAtlas.png"];
        [self addChild:mainBatchNode z:10];

		[self setupSounds];
		[self setupPhysicsWorld];

        player = [Runner spriteWithSpriteFrameName:@"Roll-Cycle-3.png"];
        player.position = ccp(-50.0, screenSize.height-100);
        [mainBatchNode addChild:player];
        [player createPhysicsObject:world];

        meteor = [Meteor spriteWithSpriteFrameName:@"meteor.png"];
        [meteor createPhysicsObject:world];
        meteor.visible = NO;
        meteor.body->SetActive(NO);
        [self addChild:meteor z:200];

        
#if USE_RANDOM_BUILDINGS
        [self createBuildings];
#else
        currentTileRightEdge = 0;
		currentTileMapNode = nil;
        tileMapToBodies = [[NSMutableDictionary alloc] init];
        [self addRandomTileMap];
#endif

		system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"powerup_explode.plist"];
		system.positionType = kCCPositionTypeFree;
		system.autoRemoveOnFinish = NO;
		system.position = ccp(-500, 0);
		[self addChild:system z:10 tag:TAG_POWERUP_EXPLODE];
		
	//	self.scale = ZOOM_FACTOR;
		self.scale = MAX_ZOOM_OUT;
        [self createLetterbox];        
	}
	return self;
}

- (void) introEffect {
    MainGameScene *mainScene = (MainGameScene*)[self parent];
    [mainScene quake];
    [[SimpleAudioEngine sharedEngine] playEffect:@"crumble.caf"];
    [[ParallaxBackgroundLayer sharedLayer] startMeteorSystemIsForIntro:YES];    
}



- (void) onEnter {
    [super onEnter];
    [self scheduleUpdate];
    [self schedule:@selector(startLiftingLetterbox) interval:7.0];
    
    // Send meteor. Wait at least X seconds, plus some random seconds (up to Y).
    [self schedule:@selector(queueMeteorShower) interval:rules.meteor_base_interval+CCRANDOM_0_1() * rules.meteor_random_interval];        

    [player BANG];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.25f], [CCCallFunc actionWithTarget:self selector:@selector(introEffect)], nil]];
}

-(void) registerWithTouchDispatcher
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) setupSounds {
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb_hit.caf"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"crumble.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"thunderRain.wav"];
}

-(void) setupDebugDraw {
	m_debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(m_debugDraw);
	uint32 flags = 0;
	flags += b2DebugDraw::e_shapeBit;
	m_debugDraw->SetFlags(flags);	
}

-(void) setupPhysicsWorld {
    b2Vec2 gravity = b2Vec2(0.0f, GRAVITY);
#if USE_FIXED_TIMESTEP
    physics = new PhysicsSystem();
    world = physics->getWorld();
#else
    bool doSleep = true;
    world = new b2World(gravity, doSleep);
#endif
    
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
#if USE_SEMI_FIXED_TIMESTEP
    world->SetAutoClearForces(false);
#endif
    
    [self setupDebugDraw];	
}

-(void) startLiftingLetterbox {
    [self unschedule:@selector(startLiftingLetterbox)];
    startLiftingLetterbox = YES;
}

- (void) createLetterbox {
    top = [CCSprite spriteWithSpriteFrameName:@"Letterbox.png"];
    bottom = [CCSprite spriteWithSpriteFrameName:@"Letterbox.png"];
    top.anchorPoint = ccp(0, 0);    
    bottom.anchorPoint = ccp(0, 0);
    
    bottom.scale = 2.0 / self.scale;
    top.scale = 2.0 / self.scale;
    top.position = ccp(player.position.x - PLAYER_LEADOUT_OFFSET/self.scale, screenSize.height/self.scale - 130 + letterBoxIncrement);
    bottom.position = ccp(player.position.x - PLAYER_LEADOUT_OFFSET/self.scale, -150 - letterBoxIncrement);
    
    [self addChild:top z:200];
    [self addChild:bottom z:200];
}

-(void) initGameRules {
    rules.meteor_base_interval = 37.f;
    rules.meteor_random_interval = 13.f;
    rules.speed_boost_duration = 3;
    rules.num_jumps_allowed_in_air = 1;
    rules.speed_extension_duration = 0.25f;
    
    // Make sure they are not multiples of each other. 
    // 1. Don't want multiple power ups appearing at the same time
    // 2. It may be skipped because if-elseif is used
    rules.num_buildings_before_speed_boost_x_1 = 3;
    rules.num_buildings_before_speed_boost_x_2 = 8;
    rules.num_buildings_before_double_jump = 7;
    rules.num_buildings_before_speed_boost_extender = 5;
    rules.num_buildings_before_flight = 11;
    
    rules.bldg_crumble_probability = 0.5;
    
    rules.max_zoom_out = MAX_ZOOM_OUT;
    
    rules.jump_force = JUMP_IMPULSE_FORCE;
}


#pragma mark -
#pragma mark Tilemap and random tilemap
#ifndef USE_RANDOM_BUILDINGS
-(void) addRandomTileMap {
    // save the old values so we can clean up the old tile once it's off screen
	oldTileRightEdge = currentTileRightEdge;
	oldTileMapNode = currentTileMapNode;
	
	// Pick a random tile from the tileset
	int mapNum = (CCRANDOM_0_1() * 3) + 1;
	currentTileMapNode = [CCTMXTiledMap tiledMapWithTMXFile:
						  [NSString stringWithFormat:@"scroller.tmx", mapNum]];
	currentTileMapNode.anchorPoint = ccp(0, 0);
	currentTileMapNode.position = ccp(oldTileRightEdge, 0);	
	CCLOG(@"tileSize = %f, mapWidth = %f", currentTileMapNode.tileSize.width, currentTileMapNode.mapSize.width);
	
	// The pixel location of the right edge of the map will be tileSize * mapSize
	currentTileRightEdge = (int)(currentTileMapNode.tileSize.width * currentTileMapNode.mapSize.width) + oldTileRightEdge;
	[self addChild:currentTileMapNode z:10];
	
	// Create a list to store all bodies for the current tile map and save it to the map.
	// bodies will be saved to it in the makeBox2dObjAt method.  The currentTileRightEdge
	// is used as the key as it will be unique to each map and can be used as a key into
	// a map, unlike CCTMXTiledMap
	CCLOG(@"addRandomMap: adding new entry to tileMapToBodies with key %d", currentTileRightEdge);
	NSMutableArray *bodies = [[NSMutableArray alloc] init];
	[tileMapToBodies setObject:bodies forKey:[NSNumber numberWithInt:currentTileRightEdge]];
	
	[self drawCollisionTiles:oldTileRightEdge];
}

-(void) destroyTileMapBodies:(CCTMXTiledMap *)map withKey:(NSNumber *)key
{	
	// Retrieve the list of bodies and destroy them
	CCLOG(@"In destroyTileMapBodies for key %@", key);
	
	// Get the list of bodies for the specified map and then remove the map from the dictionary
	NSMutableArray *bodies = [tileMapToBodies objectForKey:key];
	
	if (bodies == nil)
	{
		CCLOG(@"destroyTileMapBodies: No list of bodies was found.");
		return;
	}
	
	// For each body, destroy all fixtures and then destroy the body itself
	for (NSValue *val in bodies)
	{
		b2Body *body = (b2Body *)[val pointerValue];
		CCLOG(@"  Destroying body at position %f, %f", body->GetPosition().x, body->GetPosition().y);	
		
		// This destroys the fixtures automatically
		world->DestroyBody(body);
	}
	
	// Release the array
	[tileMapToBodies removeObjectForKey:key];
	[bodies release];
}
#endif

#pragma mark -
#pragma mark Accessors / Convenience methods
-(Runner*) runner {
	return player;
}

-(CCParticleSystem*) system {
	return system;
}

#pragma mark -
#pragma mark Touch handling
    
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    player.isMousePressed = YES;
    
    if (gameOver)
        return YES;
        
    if (player.isFlying == NO && [player runnerState] != kRunnerJumping 
        && ([player runnerState] != kRunnerFalling || [player powerUpDoubleJumpCount] > 0)) {
		[player jump];
	} 
    else if (player.isFlying) {
        if (player.runnerState == kRunnerGliding) {
            [player flyingAnimationInAir];
        }
    } 
    
    touchStart = [touch locationInView:[touch view]];
    touchStart = [[CCDirector sharedDirector] convertToGL:touchStart];

	return YES;
}

- (BOOL) isSwipeUp:(CGPoint) touchEnd {
    // Detect swipe up
    if (!player.entranceMode && touchStart.y - touchEnd.y < 0) {
        int distance = abs((touchStart.y - touchEnd.y));
        int distanceX = abs((touchStart.x - touchEnd.x));
        
        if (distanceX > swipeTolerance) {
            return NO;
        } else if (distance > swipeTolerance) {
            return YES;
        }        
    }
    return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {    
    player.isMousePressed = NO;

    CGPoint touchEnd = [touch locationInView:[touch view]];
    touchEnd = [[CCDirector sharedDirector] convertToGL:touchEnd];

    // Detect swipe right
//    if (touchStart.x - touchEnd.x < 0) {
//        int distance = abs((touchStart.x - touchEnd.x));
//        int distanceY = abs((touchStart.y - touchEnd.y));
//        
//        if (distanceY > swipeTolerance) {
//            // NO
//        } else if (distance > swipeTolerance) {
//            // Yes
//            CCLOG(@"*** Swipe right detected. Flying!");
//            world->SetGravity(b2Vec2(0, FLIGHT_ATTEMPT_GRAVITY));
//            [player startFlying];
//        }        
//    }

    // Detect swipe up
    if ([self isSwipeUp:touchEnd]) {
        CCLOG(@"*** Swipe right detected. Flying!");
        world->SetGravity(b2Vec2(0, FLIGHT_ATTEMPT_GRAVITY));
        [player startFlying];        
    } else {
        if (player.isFlying) {
            if (player.runnerState == kRunnerFlying) {
                [player glideAnimation];
            }
        }
    }
}


#pragma mark -
#pragma mark Support methods
#ifndef USE_RANDOM_BUILDINGS
-(void) makeBox2dObjAt:(CGPoint)p 
              withSize:(CGPoint)size 
               dynamic:(BOOL)d 
              rotation:(long)r 
              friction:(long)f 
               density:(long)dens 
           restitution:(long)rest 
                 boxId:(int)boxId {
	CCLOG(@"Add rect %0.2f x %02.f",p.x,p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.angle = r * M_PI/180;
	
	if (d)
		bodyDef.type = b2_dynamicBody;
	
	GameObject *ground = [[GameObject alloc] init];
	ground.gameObjectType = kGameObjectPlatform;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = ground;
	
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(size.x/2/PTM_RATIO, size.y/2/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = dens;
	fixtureDef.friction = f;
	fixtureDef.restitution = rest;
	body->CreateFixture(&fixtureDef);
	
	// Save the body so it can be destroyed once it goes off screen
	NSMutableArray *bodies = [tileMapToBodies objectForKey:[NSNumber numberWithInt:currentTileRightEdge]];
	
	// b2Body is not an Objective C class so we need to wrap it in NSValue in order to be able to 
	// store it in a NSMutableArray
	[bodies addObject:[NSValue valueWithPointer:body]];
}

-(void) drawCollisionTiles:(int)x_offset {
	CCLOG(@"  drawCollisionTiles:%d", x_offset);
	CCTMXObjectGroup *objects = [currentTileMapNode objectGroupNamed:@"Collision"];
	NSMutableDictionary * objPoint;
	
	int x, y, w, h;	
	for (objPoint in [objects objects]) {
		x = [[objPoint valueForKey:@"x"] intValue] + x_offset;
		y = [[objPoint valueForKey:@"y"] intValue];
		w = [[objPoint valueForKey:@"width"] intValue];
		h = [[objPoint valueForKey:@"height"] intValue];	
		NSString *s = [objPoint valueForKey:@"name"];
		CGPoint _point=ccp(x+w/2,y+h/2);
		CGPoint _size=ccp(w,h);
		
		if ([s isEqualToString:@"dynamic"]) {
			[self makeBox2dObjAt:_point withSize:_size dynamic:true rotation:0 friction:0.0f density:0.001f restitution:0 boxId:-1];
		} else if ([s isEqualToString:@"wall"]) {
			[self makeBox2dObjAt:_point withSize:_size dynamic:false rotation:-10.0 friction:0.0f density:0.0f restitution:0.2 boxId:-1];
		} else if ([s isEqualToString:@"powerup"]) {
			PowerUpSpeedBoost *powerUp = [PowerUpSpeedBoost spriteWithFile:@"powerup.png"];
			powerUp.position = ccp(_point.x, _point.y);
            //		powerUp.scale = 0.7;
			[powerUp createPhysicsObject:world];
			[self addChild:powerUp];			
		} else if ([s isEqualToString:@"powerupdj"]) {
            PowerUpDoubleJump *powerUp = [[PowerUpDoubleJump alloc] init];
            
			powerUp.position = ccp(_point.x, _point.y);
            //		powerUp.scale = 0.7;
			[powerUp createPhysicsObject:world];
			[self addChild:powerUp];			
		} else if ([s isEqualToString:@"crow"]) {
            for (int i = 0; i < 20; i++) {
                Crow *crow = [Crow spriteWithSpriteFrameName:@"dove4.png"];
                if (CCRANDOM_MINUS1_1() < 0) {
                    crow.flipX = YES;
                }
                crow.scale = 3.0;
                crow.position = ccp(_point.x + i*(20 + CCRANDOM_0_1() * 30), _point.y);
                [crow createPhysicsObject:world];
                [mainBatchNode addChild:crow];
            }
        } else {
			[self makeBox2dObjAt:_point withSize:_size dynamic:false rotation:0 friction:0.0 density:0.0f restitution:0 boxId:-1];
		}
	}
}
#endif

-(void) draw {
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}


-(void) displayGameOver {
    [self unschedule:@selector(displayGameOver)];
    
    if (preCleanup == NO) {
        preCleanup = YES;
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        // Get distance and remove player from game
        int distance = [player body]->GetPosition().x;
        world->DestroyBody([player body]);
        [self removeChild:player cleanup:YES];
        
        MainGameScene *main = (MainGameScene*)[self parent];
        [[main uiLayer] showGameOverMenu:distance];
    }
}

#ifdef DEBUG
- (int) numActiveBuildings {
    int numActiveBldgs = 0;        
    for (int m = 0; m < 3; m++) {
        Building *b;
        for (NSUInteger n = 0; n < [buildingsGroupedByHeight[m] count]; n++) {
            b = [buildingsGroupedByHeight[m] objectAtIndex:n];
            if (b.visible) {
                numActiveBldgs++;   
            }
        }
    }
    return numActiveBldgs;
}
#endif

#pragma mark -
#pragma mark Main game loop
-(void)afterStep {
	// process collisions and result from callbacks called by the step
}

#if USE_SEMI_FIXED_TIMESTEP
-(void)step:(ccTime)dt {
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
#endif

-(void) update:(ccTime)dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
    
#if USE_VARIABLE_TIMESTEP
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
    
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
#endif
    
#if USE_FIXED_TIMESTEP
	physics->update(dt);
#endif
    
#if USE_SEMI_FIXED_TIMESTEP
    [self step:dt];
#endif
    
    // Update player first before everything else
    [player updateObject:dt];
    
    if (killerMeteorQueued) {
        killerMeteorQueued = NO;
        float sendMeteorIn = (MAX_ZOOM_OUT / (self.scale + CCRANDOM_0_1()*0.5));
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:sendMeteorIn], [CCCallFunc actionWithTarget:self selector:@selector(sendMeteor)], nil]];
    }

	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
		_gameObject = (GameObject*)b->GetUserData();
		if (_gameObject != NULL) {
            switch (_gameObject.gameObjectType) {
                case kGameObjectPowerUpSpeedBoost:
                case kGameObjectPowerUpDoubleJump:
                case kGameObjectPowerUpSpeedBoostExtender:
                case kGameObjectPowerUpFlight:
                    _powerup = (PowerUp*)_gameObject;
                    if (_powerup.state == kPowerUpStateDestroy) {
                        [_powerup explode];
                        world->DestroyBody(b);
                        [self removeChild:_gameObject cleanup:YES];
                    }
                    break;
                case kGameObjectCrow:
                    _crow = (Crow*)_gameObject;
                    if (_crow.state == kBirdSitting) {
                        if (_crow.position.x - player.position.x < 270) {
                            [_crow fly];
                        }
                    } else if (_crow.state == kBirdDestroy) {
                        world->DestroyBody(b);
                        [mainBatchNode removeChild:_gameObject cleanup:YES];
                    }
                    break;
                case kGameObjectMeteor:
                    if (_gameObject.visible) {
                        _meteor = (Meteor*)_gameObject;
                        [_meteor updateObject:dt];
                        if (_meteor.position.y < 0 || _meteor.position.x + 30 < player.position.x || _meteor.state == kMeteorStateDestroy) {
                            [_meteor explode]; 
                            // Call DestroyBody here instead of inside dealloc of the gameObject, else it crashes
                            // because dealloc may be called too slow (and thus the object may still exist and deleted twice)
                            // world->DestroyBody(b);
                            //[self removeChild:_gameObject cleanup:YES];	// Retain count should be 1
                            
                            [_meteor setVisible:NO];
                            b->SetActive(NO);
                            // Don't uncomment below or it will crash
                            // [gameObject release];	// Retain count be 0, and dealloc should be called
                        } 
                    }
                    break;
                case kGameObjectPlatform:
                    if (_gameObject.visible) {
                        [_gameObject updateObject:dt];
                    }
                    break;
                default:
                    break;
            }
		}
	}	
    
#if USE_RANDOM_BUILDINGS    
    // There are two reasons for minimizing the number of objects drawn on the screen. 
    // 1. Having less objects drawn will increase performance. 
    // 2. Because we are using the player's velocity to calculate the gap between two buildings, it's important to
    //      calculate as few as possible. The more buidings we pregenerate, the less we can be sure about what the
    //      player's velocity will be, thus the gap will be wrong after the first one. The velocity may be correct for the 
    //      first gap between the building, but may be incorrect for subsequent ones (due to slow down or new power up in between).
    //      In other words, if we pre-generate more than one, we would be using the outdated velocity.
    
    // If the player's is beyond the building's right edge, then we disable the building.
    // However, because the player has a leadout, we must account for that (as well as the zoom factor).
    if (previousBuilding.visible && player.position.x > previousBuilding.position.x + previousBuilding.size.width + (PLAYER_LEADOUT_OFFSET / self.scale)) {
        [previousBuilding setVisible:NO];
        [previousBuilding stopCrumble];
    }  else {
        // Draw only one building ahead. Because the size of our smallest building is at least twice the size of the 
        // standard iPhone screen, if the right edge of the building is about to make come into view, enable the next 
        // buiding. Because we have a player leadout, we also adjust for that as well adjust for the zoom factor. 
        if (currentBuilding.position.x + currentBuilding.size.width < ((player.position.x - PLAYER_LEADOUT_OFFSET) + (screenSize.width / self.scale))) {
            //                  +---------------+
            //                  |  *   screen   |   * = player
            // +----------------|---------------|
            // |  building      |               |
            // +----------------+---------------+
            
            // User may have speed boost, but it may run out before reaching end of building (IOW, speed back to normal max)
            // How to figure this out?
            // Is player's speed boost mode currently in effect?
            //      if in effect, will it be in effect when player reaches end of building?
            
            
            // Is player's speed boost mode in drain mode? 
            //      if in drain mode, how much longer will it be in effect?
            [self moveBuildingAfter:currentBuilding];
        }    
    }
#endif	
    
    if (player.entranceMode == NO) {
        // Zoom effect
        _zFactor = ZOOM_OUT_FACTOR * ([player body]->GetLinearVelocity().x / MAX_RUN_SPEED);
#if SMOOTH_ZOOM
        _oldScale = self.scale;
        _newScale = ZOOM_FACTOR - _zFactor;
        
        _dScale = _oldScale - _newScale;
        _zRate = fabs(_dScale) / dt;
        // hit max zoom rate, throttle the zoomging rate
        if (_zRate > ZOOM_RATE) {
            //	gameOver = false;	// If game is over, but we're zooming, don't end the game yet.
            _newScale = _dScale > 0 ? _oldScale - ZOOM_RATE * dt : _oldScale + ZOOM_RATE * dt;
        }
#else
        _newScale = ZOOM_FACTOR - _zFactor;
#endif
    
        if (_newScale > rules.max_zoom_out) {
            // Synthesized version of scale is set to 'assign', so it doesn't check
            // if new value is same as old value. So check it explicitly here.
            if (_newScale != self.scale) {
                self.scale = _newScale;
                
                _mgs = (MainGameScene*)[self parent];
    //            _parallaxBatchNode = [[_mgs parallaxBackground] spriteBatch];
                [[_mgs parallaxBackground] setParallaxSpeed:[player body]->GetLinearVelocity().x / 7.0f];
                [[_mgs parallaxBackground] setZoom:_newScale];
    //            _parallaxBatchNode.scale = _newScale;
            }
        }
    } else {
        leadout_offset += 2.0;
        if (leadout_offset >= PLAYER_LEADOUT_OFFSET) {
            leadout_offset = PLAYER_LEADOUT_OFFSET;   

        }
    }

    
    // Letterbox effect. Scale the bars so it's big, and don't worry about the finer details of keeping
    // it in pace with the player exactly as it'll be removed from the scene once out of view anyway.
    if (letterBoxShowing) {
        bottom.scale = 2.0 / self.scale;
        top.scale = 2.0 / self.scale;
        top.position = ccp(player.position.x - PLAYER_LEADOUT_OFFSET/self.scale - 20, screenSize.height/self.scale - 130 + letterBoxIncrement);
        bottom.position = ccp(player.position.x - PLAYER_LEADOUT_OFFSET/self.scale -  20, -150 - letterBoxIncrement);
        if (startLiftingLetterbox) {
            letterBoxIncrement += 1.f;
        }
        if (-letterBoxIncrement < -200.f) {
            CCLOG(@"****** Remove letterbox");
            letterBoxShowing = NO;
            [top setVisible:NO];
            [bottom setVisible:NO];
            [self removeChild:top cleanup:YES];
            [self removeChild:bottom cleanup:YES];
        }
    }
    
    self.position = ccp(-1 * [player body]->GetPosition().x * self.scale * PTM_RATIO + leadout_offset, self.position.y);
    
    if (!player.visible) {
		gameOver = true;
        if (calledDisplayGameOver == NO) {
            calledDisplayGameOver = YES;
            [player body]->SetLinearVelocity(b2Vec2(0, 0));
            [player setVisible:NO];
            
            // Don't call gameOver right away as it has an unwanted effect.
            [self schedule:@selector(displayGameOver) interval:1];
        }
	}
}

#pragma mark -
#pragma mark Random building generation
-(void) moveBuildingAfter:(Building *) b {
    PowerUpToAdd powerUpToAdd = kPowerUpToAddNone;
    
    previousBuilding = currentBuilding;
    if (player.runnerState == kRunnerFlying && landingBuilding.visible == NO) {
        currentBuilding = landingBuilding;
    } else {
        int groupNo;
        int index;
        powerUpToAdd = [self getPowerUpToAdd];
        if (powerUpToAdd == kPowerUpToAddNone || powerUpToAdd == kPowerUpToAddFlight) {
            groupNo = rand() % (b.numTilesHigh+1);
            if (groupNo > BUILDING_MAX_HEIGHT_TILES-2) {
                groupNo = BUILDING_MAX_HEIGHT_TILES-2;
            }
        } else {
            groupNo = rand() % (BUILDING_MAX_HEIGHT_TILES-1);
        }
        int count = [buildingsGroupedByHeight[groupNo] count];
//        CCLOG(@"*** groupNo = %d   count = %d", groupNo, count);
        NSAssert(count >= 2, @"Guanrantee that there are at least 2 buildings at each height");
        index = rand() % count;
        currentBuilding = [buildingsGroupedByHeight[groupNo] objectAtIndex:index];  // Does not increase ref count
        if (previousBuilding == currentBuilding) {
            if (index >= 0 && index < count-1) {
                CCLOG(@"**** Current == Previous, in between, incrementing");
                ++index;
            } else {
                CCLOG(@"**** current == Previous, at max, decrementing");
                --index;
            }
            currentBuilding = [buildingsGroupedByHeight[groupNo] objectAtIndex:index];
        }
    }
    
    int gap = [self calculateGap:powerUpToAdd];        
    
    // Move the building to the right of the current last building b
    currentBuilding.position = ccp(b.position.x + b.size.width + gap, 0);
    CGPoint newP = ccp(currentBuilding.position.x + currentBuilding.size.width/2 + JUMP_ERROR_BUFFER, currentBuilding.size.height/2);
    b2Body *moveBody = [currentBuilding body];
    moveBody->SetTransform(b2Vec2(newP.x/PTM_RATIO, newP.y/PTM_RATIO), 0);
    [currentBuilding setVisible:YES];
    
    if ([currentBuilding numTilesHigh] - [b numTilesHigh] >= 2) {
        CCLOG(@"**** Increasing jump force, next building is too high");
        rules.jump_force += 3;
    } else {
        rules.jump_force = JUMP_IMPULSE_FORCE;
    }
    
    [self addPowerup:powerUpToAdd toLeftBuilding:b andRightBuilding:currentBuilding];
    [player setNextBuilding:currentBuilding];
    // [self createBridgeFrom:b to:move]; 
    
    // add crows to some buildings
    if ((CCRANDOM_0_1()*4) >= 3)
    {
        int numCrows = 3+(CCRANDOM_0_1()*27);
        int x=currentBuilding.position.x + 80;
        // sometimes start the crows in the middle of the building instead
        // of at the left edge
        if (CCRANDOM_MINUS1_1() < 0)
            x = currentBuilding.position.x + (currentBuilding.size.width/2) - 80;
        
        int y=currentBuilding.size.height+12;
        int maxX = currentBuilding.position.x + currentBuilding.size.width - 40;
        for (int i = 0; i < numCrows && (x + i*50) < maxX; i++) {
            Crow *crow = [Crow spriteWithSpriteFrameName:@"Crow6.png"];
            if (CCRANDOM_MINUS1_1() < 0) {
                crow.flipX = YES;
            }
            crow.position = ccp(x + i*(20 + CCRANDOM_0_1() * 30), y);
            [crow createPhysicsObject:world];
            [mainBatchNode addChild:crow];
        }
    }        
}

-(void) addPowerup:(PowerUpToAdd)powerUpToAdd toLeftBuilding:(Building*)left andRightBuilding:(Building*)right {
    PowerUp     *pu;    
    float       x = left.position.x + left.size.width;
    float       y = left.position.y + left.size.height + 80;        
    
    switch (powerUpToAdd) {
        case kPowerUpToAddSpeedBoostX2:
            pu = [PowerUpSpeedBoost spriteWithSpriteFrameName:@"powerup.png"];
            pu.scale = 0.7;
            pu.position = ccp(x, y);
            [pu createPhysicsObject:world];
            [self addChild:pu];
            
            pu = [PowerUpSpeedBoost spriteWithSpriteFrameName:@"powerup.png"];
            pu.scale = 0.7;
            pu.position = ccp(x + 40, y + 25);
            [pu createPhysicsObject:world];
            [self addChild:pu];
            
            break;
        case kPowerUpToAddSpeedBoostX1:
            pu = [PowerUpSpeedBoost spriteWithSpriteFrameName:@"powerup.png"];
            pu.scale = 0.7;
            pu.position = ccp(x, y);
            [pu createPhysicsObject:world];
            [self addChild:pu];
            
            break;
        case kPowerUpToAddDoubleJump:
            pu = [PowerUpDoubleJump spriteWithFile:@"rain.png"];                
            pu.scale = 0.7;
            pu.position = ccp(x, y);
            [pu createPhysicsObject:world];
            [self addChild:pu];
            break;
        case kPowerUpToAddFlight:
            pu = [PowerUpFlight spriteWithSpriteFrameName:@"PowerUpFlight.png"];
            pu.position = ccp(x, y);
            [pu createPhysicsObject:world];
            [self addChild:pu];                        
            break;
        case kPowerUpToAddSpeedBoostExtender:
            pu = [PowerUpSpeedBoostExtender spriteWithFile:@"Icon.png"];
            pu.scale = 0.7;
            pu.position = ccp(right.position.x + right.size.width/2, right.position.y + right.size.height + 100);
            [pu createPhysicsObject:world];
            [self addChild:pu];
            break;
        case kPowerUpToAddNone:
            break;
    }
}

- (PowerUpToAdd) getPowerUpToAdd {
    if (player.coolOff == kCoolOffOff) {
        ++buildingsSinceLastDoubleJump;
        ++buildingsSinceLastSpeedBoostX1;
        ++buildingsSinceLastSpeedBoostX2;
        ++buildingsSinceLastSpeedExtender;
        ++buildingsSinceLastFlight;

        if (buildingsSinceLastSpeedBoostX2 >= rules.num_buildings_before_speed_boost_x_2) {
            buildingsSinceLastSpeedBoostX2 = 0;
            return kPowerUpToAddSpeedBoostX2;            
        } else if (buildingsSinceLastSpeedBoostX1 >= rules.num_buildings_before_speed_boost_x_1) {
            buildingsSinceLastSpeedBoostX1 = 0;
            return kPowerUpToAddSpeedBoostX1;
        } else if (buildingsSinceLastDoubleJump >= rules.num_buildings_before_double_jump) {
            buildingsSinceLastDoubleJump = 0;
            return kPowerUpToAddDoubleJump;
        } else if (buildingsSinceLastFlight >= rules.num_buildings_before_flight) {
            buildingsSinceLastFlight = 0;
            return kPowerUpToAddFlight;
        } else if (buildingsSinceLastSpeedExtender >= rules.num_buildings_before_speed_boost_extender) {
            buildingsSinceLastSpeedExtender = 0;
            return kPowerUpToAddSpeedBoostExtender;
        }
    }     
    return kPowerUpToAddNone;    
}

-(int) calculateGap:(PowerUpToAdd)powerUpToAdd {
    float gap = BUILDING_MIN_GAP_PX + (CCRANDOM_0_1() * (BUILDING_MAX_GAP_PX - BUILDING_MIN_GAP_PX));
    if (player.isFlying) {
        return gap;
    }
    float speed = [player body]->GetLinearVelocity().x;
    switch (powerUpToAdd) {
        case kPowerUpToAddSpeedBoostX2:
            if ([player canMakeToEndOfBuildingWithSpeedBoost]) {
                gap = speed * (80 + (speed - MAX_RUN_SPEED) / (MAX_RUN_SPEED-13));
                CCLOG(@"-------------------------> gap=%f speed-maxspeed=%f", gap, (speed - MAX_RUN_SPEED) / (MAX_RUN_SPEED-13));
                
            } else {
                gap = speed * 60;
            }
            break;
        case kPowerUpToAddSpeedBoostX1:
            if ([player canMakeToEndOfBuildingWithSpeedBoost]) {
                gap = speed * (55 + (speed - MAX_RUN_SPEED) / MAX_RUN_SPEED);
                CCLOG(@"==========================> gap=%f speed-maxspeed=%f", gap, (speed - MAX_RUN_SPEED) / MAX_RUN_SPEED);
                
            } else {
                gap = speed * 45;
            }
            
            if (CCRANDOM_0_1() >= 0.0) {
                buildingsSinceLastSpeedBoostX2 = rules.num_buildings_before_speed_boost_x_2;
            }
            break;
        case kPowerUpToAddDoubleJump:
            gap += 150 + (rand() % 50);
            break;
        case kPowerUpToAddFlight:
        case kPowerUpToAddNone:
        case kPowerUpToAddSpeedBoostExtender:
            break;
    }
    
    return gap;    
}

-(void) createBuildings {    
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    for (int i = 0; i < BUILDING_MAX_HEIGHT_TILES-1; i++) {
        buildingsGroupedByHeight[i] = [[CCArray alloc] init];
        // Store at least two buildings in each so that none of the array is empty (on the off chance
        // that the random number generator doesn't generate the building for one of the building heights).
        Building *building1 = [[Building alloc] initBuildingWithHeight:i+1];
        Building *building2 = [[Building alloc] initBuildingWithHeight:i+1];

        [building1 createPhysicsObject:world];
        [building1 setVisible:NO];
        [self addChild:building1];
        [buildingsGroupedByHeight[i] addObject:building1];

        [building2 createPhysicsObject:world];
        [building2 setVisible:NO];
        [self addChild:building2];
        [buildingsGroupedByHeight[i] addObject:building2];
    }
    
    for (int i = 0; i < NUM_BUILDINGS; i++) {
        Building *building;
        building = [[Building alloc] initAt:-5000.0f];
        [buildingsGroupedByHeight[building.numTilesHigh-1] addObject:building];
        [building createPhysicsObject:world];
        [building setVisible:NO];
        [self addChild:building];
        
    }
    
    // Very first building shown on screen, and building shown on screen frequently when flying to make it easier to land
    landingBuilding = [[Building alloc] initLandingBuilding];
    landingBuilding.position = ccp(8000.0, 0);    
    [landingBuilding createPhysicsObject:world];
    [landingBuilding setVisible:YES];
    [self addChild:landingBuilding];
    currentBuilding = landingBuilding;
    previousBuilding = currentBuilding;
}

// Do not delete below
/*
 - (void)createBridgeFrom:(Building*)b1 to:(Building*)b2 {    
 //    Box2DSprite *lastObject;
 b2Body *lastBody = [b1 body];
 float groundMax = b1.position.x + b1.size.width;
 for(int i = 0; i < 20; i++) {        
 //      Box2DSprite *plank = [Box2DSprite spriteWithSpriteFrameName:@"plank.png"]; 
 //      plank.gameObjectType = kGroundType;
 
 b2BodyDef bodyDef;
 bodyDef.type = b2_dynamicBody;
 bodyDef.position = b2Vec2(groundMax/PTM_RATIO, (b1.position.y + b1.size.height - 40.0)/PTM_RATIO);
 
 b2Body *plankBody = world->CreateBody(&bodyDef);
 //      plankBody->SetUserData(plank);
 //      plank.body = plankBody;
 //      [groundSpriteBatchNode addChild:plank];
 
 b2PolygonShape shape;                
 shape.SetAsBox(50.0f/2/PTM_RATIO, 20.0f/2/PTM_RATIO);
 
 b2FixtureDef fixtureDef;
 fixtureDef.shape = &shape;
 fixtureDef.density = 2.0;
 fixtureDef.friction = 0.0;
 plankBody->CreateFixture(&fixtureDef);
 
 b2RevoluteJointDef jd;
 jd.Initialize(lastBody, plankBody, plankBody->GetWorldPoint(b2Vec2(-50.0f/2/PTM_RATIO, 0)));
 jd.lowerAngle = CC_DEGREES_TO_RADIANS(-0.25);
 jd.upperAngle = CC_DEGREES_TO_RADIANS(0.25);
 jd.enableLimit = true;
 b2Joint *joint = world->CreateJoint(&jd);          
 if (i == 0) { lastBridgeStartJoint = joint; }
 
 groundMax += (50.0f * 0.8);
 lastBody = plankBody;
 //    lastObject = plank;        
 }
 
 b2RevoluteJointDef jd;
 jd.Initialize(lastBody, [b1 body], lastBody->GetWorldPoint(b2Vec2(20.0f/2.0f/PTM_RATIO, 0)));
 lastBridgeEndJoint = world->CreateJoint(&jd);    
 }
 */

-(void) queueMeteorShower {
    // First, unschedule
    [self unschedule:@selector(queueMeteorShower)];
    
    meteorShowerQueued = kMeteorShowerQueueQueued;
}

- (void) sendMeteorShower {
    if (meteorShowerQueued == kMeteorShowerQueueQueued && killerMeteorQueued == NO) {
        meteorShowerQueued = kMeteorShowerQueueQueuedSendKillerMeteor;
        // Send background meteor shower to signal that meteor is imminent
        [[ParallaxBackgroundLayer sharedLayer] startMeteorSystemIsForIntro:NO];
     
        // In 10 plus or minus 0-4 seconds, send down meteor
        // [self schedule:@selector(queueMeteor) interval:(rand()%5)+7];    
    }
}

- (void) queueMeteor {
//    [self unschedule:@selector(queueMeteor)];
    if (meteorShowerQueued == kMeteorShowerQueueQueuedSendKillerMeteor && !killerMeteorQueued && [[ParallaxBackgroundLayer sharedLayer] areAllMeteorsOffScreen]) {
        meteorShowerQueued = kMeteorShowerQueueCleared;
        killerMeteorQueued = YES;
    }
}

- (void) sendMeteor {
    if ([[ParallaxBackgroundLayer sharedLayer] areAllMeteorsOffScreen]) {
        if ([player.building isCrumbling] == NO) {
            killerMeteorQueued = NO;
            meteor.position = ccp(player.position.x + ((screenSize.width+20)/self.scale), ((screenSize.height+20)/self.scale));
            meteor.body->SetTransform(b2Vec2(meteor.position.x/PTM_RATIO, meteor.position.y/PTM_RATIO), 0);
            [meteor setVisible:YES];
            meteor.body->SetActive(YES);
            
            [self schedule:@selector(queueMeteorShower) interval:rules.meteor_base_interval+CCRANDOM_0_1() * rules.meteor_random_interval];
        }
    }
}

#pragma mark -
#pragma mark Clean-up

-(void) dealloc {
	delete contactListener;
	
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    
    for (int i = 0; i < BUILDING_MAX_HEIGHT_TILES-1; i++) {
        [buildingsGroupedByHeight[i] release];
    }

    [landingBuilding release];
    
//	[activeBuildings release];
//  [inactiveBuildings release];
    
    // auto released
    //    currentTileMapNode
    //    oldTileMapNode
    //    player
    //    system
    //    mainBatchNode
    //    crowBatchNode
    
    
    // not used for random building
    //	tileMapToBodies;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
